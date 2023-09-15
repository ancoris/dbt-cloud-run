{% materialization scd2_events, default %}
  {%- set config = model['config'] -%}

  {%- set target_table = model.get('alias', model.get('name')) -%}

  {% if not adapter.check_schema_exists(model.database, model.schema) %}
    {% do create_schema(model.database, model.schema) %}
  {% endif %}

  {% set target_relation_exists, target_relation = get_or_create_relation(
          database=model.database,
          schema=model.schema,
          identifier=target_table,
          type='table') -%}

  {%- if not target_relation.is_table -%}
    {% do exceptions.relation_wrong_type(target_relation, 'table') %}
  {%- endif -%}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set strategy = scd2_events_strategy(model, config) %}

  {% if not target_relation_exists and not strategy.backfill %} -- first run, backfill false

      {% set build_sql = build_initial_scd2_events_table(strategy, model['compiled_sql']) %}
      {% call statement('main') -%}
          {{ create_table_as(False, target_relation, build_sql) }}
      {% endcall %}

  {% elif not target_relation_exists and strategy.backfill %} -- first run, backfill true

      {% set build_sql = build_backfill_scd2_events_table(strategy, model['compiled_sql']) %}
      {% call statement('main') -%}
          {{ create_table_as(False, target_relation, build_sql) }}
      {% endcall %}

  {% else %}

      -- build a temp table to hold all of the interim inserts
      {% set staging_table = build_scd2_events_staging_table(strategy, sql, target_relation) %}

      {% set source_columns = adapter.get_columns_in_relation(staging_table) %}

      {% set quoted_source_columns = [] %}
      {% for column in source_columns %}
        {% do quoted_source_columns.append(adapter.quote(column.name)) %}
      {% endfor %}

      {% call statement('main') %}
          {{ scd2_events_merge_sql(
                target = target_relation,
                source = staging_table,
                insert_cols = quoted_source_columns
             )
          }}
      {% endcall %}

  {% endif %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}


{% macro scd2_events_strategy(node, config) %} -- change to config.require

    {% set check_cols         = config['check_cols'] %}
    {% set natural_key_col    = config['natural_key_col'] %}
    {% set surrogate_key_col  = natural_key_col | replace('_natural_', '_surrogate_') %}
    {% set modified_time      = config['modified_time'] %}
    {% set created_time       = config['created_time'] if config['created_time'] else modified_time %}
    {% set backfill           = config['backfill'] if config['backfill'] else false %}


    {% if not natural_key_col %}
        {% do exceptions.raise_compiler_error("No value provided for 'natural_key_col' in config.") %}
    {% endif %}

    {% if not modified_time %}
        {% do exceptions.raise_compiler_error("No value provided for 'modified_time' in config.") %}
    {% endif %}

    {% if not (check_cols is iterable and (check_cols | length) > 0) %}
        {% do exceptions.raise_compiler_error("Invalid value for 'check_cols': " ~ check_cols) %}
    {% endif %}

    {% set scd_id_expr = snapshot_hash_arguments([natural_key_col, modified_time]) %}

    {% do return({
        "natural_key": natural_key_col,
        "surrogate_key": surrogate_key_col,
        "modified_time": modified_time,
        "created_time": created_time,
        "cols_to_check": check_cols,
        "scd_id": scd_id_expr,
        "backfill": backfill
    }) %}
{% endmacro %}

{% macro build_initial_scd2_events_table(strategy, sql) %}
    -- this is run when the target table is not found
    select
        {{ strategy.scd_id }}                           as {{ strategy.surrogate_key }},
        *,
        'insert'                                        as meta_scd_action,
        cast({{ strategy.created_time }} as timestamp)  as meta_start_time
    from (
        {{ sql }}
    ) sbq

{% endmacro %}

{% macro build_backfill_scd2_events_table(strategy, sql) %}
    -- this is run when the target table is not found
    select
        {{ strategy.scd_id }}                           as {{ strategy.surrogate_key }},
        *, -- assume backfill table has these fields
        --'insert'                                        as meta_scd_action,
        --cast({{ strategy.created_time }} as timestamp)  as meta_start_time
    from (
        {{ sql }}
    ) sbq

{% endmacro %}


{% macro build_scd2_events_staging_table(strategy, sql, target_relation) %}
    {% set tmp_relation = make_temp_relation(target_relation) %}

    {% set new_rows_sql = scd2_events_staging_table_new_rows_sql(strategy, sql, target_relation) %}

    {% call statement('build_scd2_events_staging_relation_inserts') %}
        {{ create_table_as(True, tmp_relation, new_rows_sql) }}
    {% endcall %}

    {% do return(tmp_relation) %}
{% endmacro %}


{% macro row_change_detection_expr(source_a, source_b, cols) %}
  {% set row_change_detection_expr -%}
        {% for col in cols %}
            to_json_string({{ source_a }}.{{ col }}) != to_json_string({{ source_b }}.{{ col }})
            {%- if not loop.last %} or {% endif %}

        {% endfor %}
  {%- endset %}
  {% do return(row_change_detection_expr) %}
{% endmacro %}


{% macro scd2_events_staging_table_new_rows_sql(strategy, source_sql, target_relation) -%}

  -- staging records
  with source_data as (
    select  {{ strategy.scd_id }} as {{ strategy.surrogate_key }},
            *
    from    ({{ source_sql }}) sub
  ),

  -- pick the latest target record by natural key
  target_latest as (
    select  *
    from    {{ target_relation }} latest
    where   meta_start_time =
    (
      select  max(a.meta_start_time)
      from    {{ target_relation }} a
      where   a.{{ strategy.natural_key }} = latest.{{ strategy.natural_key }}
    )
    -- if we are in incremental mode then limit the target rows to only the natural keys changing
    {% if  model['config']['ignore_deletes'] == 'Y' and model.config.mode == 'incremental' %}
    and exists
    (
      select  1
      from    source_data src
      where   src.{{ strategy.natural_key }} = latest.{{ strategy.natural_key }}

    )
    {% endif %}
  )

  -- new records we have never seen before
  select  source_data.*,
          'insert'                                                      as meta_scd_action,
          cast(source_data.{{ strategy.created_time }} as timestamp)    as meta_start_time
  from    source_data
  left outer join
          target_latest
  on      target_latest.{{ strategy.natural_key }} = source_data.{{ strategy.natural_key }}
  where   target_latest.{{ strategy.natural_key }} is null -- new entry

  -- existing records that are changing
  union all
  select  source_data.*,
          'update'                                                      as meta_scd_action,
          cast(source_data.{{ strategy.modified_time }} as timestamp)   as meta_start_time
  from    source_data
  join
          target_latest
  on      target_latest.{{ strategy.natural_key }} = source_data.{{ strategy.natural_key }}
  where   target_latest.meta_scd_action <> 'delete'
  and     ({{ row_change_detection_expr('source_data', 'target_latest', strategy.cols_to_check) }})

  -- existing records now deleted
  union all
  select  target_latest.* except(meta_process_time, meta_delivery_time, meta_start_time, meta_scd_action),
          {{ meta_process_time() }} as meta_process_time,
          {{ meta_process_time() }} as meta_delivery_time,
          'delete',
          {{ meta_process_time() }} as meta_start_time
  from    target_latest
  left outer join
          source_data on target_latest.{{ strategy.natural_key }} = source_data.{{ strategy.natural_key }}
  where  target_latest.meta_scd_action <> 'delete'
  and    source_data.{{ strategy.natural_key }} is null

  -- records that are currently deleted but now appear again in source
  union all
  select  source_data.{{ strategy.surrogate_key }},
          source_data.* except({{ strategy.surrogate_key }}),
          're-activate'                                                 as meta_scd_action,
          cast(source_data.{{ strategy.modified_time }} as timestamp)   as meta_start_time
  from    source_data
  join
          target_latest
  on      target_latest.{{ strategy.natural_key }} = source_data.{{ strategy.natural_key }}
  where   target_latest.meta_scd_action = 'delete'

{%- endmacro %}


{% macro scd2_events_merge_sql(target, source, insert_cols) -%}
  {{ adapter.dispatch('scd2_events_merge_sql')(target, source, insert_cols) }}
{%- endmacro %}

{% macro default__scd2_events_merge_sql(target, source, insert_cols) -%}
  {%- set insert_cols_csv = insert_cols | join(', ') -%}

  insert into  {{ target }} ({{ insert_cols_csv }})
  select  {{insert_cols_csv}}
  from    {{ source }};

{% endmacro %}
