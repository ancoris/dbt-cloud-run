{% materialization scd2_history, default %}
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

  {% set strategy = scd2_history_strategy(model, config) %}

  {% if not target_relation_exists %}

      {% set build_sql = build_initial_scd2_history_table(strategy, model['compiled_sql']) %}
      {% call statement('main') -%}
          {{ create_table_as(False, target_relation, build_sql) }}
      {% endcall %}

  {% else %}

      -- build a temp table to hold all of the interim inserts
      {% set staging_table = build_scd2_history_staging_table(strategy, sql, target_relation) %}

      {% set source_columns = adapter.get_columns_in_relation(staging_table) %}

      {% set quoted_source_columns = [] %}
      {% for column in source_columns %}
        {% do quoted_source_columns.append(adapter.quote(column.name)) %}
      {% endfor %}

      {% call statement('main') %}
          {{ scd2_history_merge_sql(
                target = target_relation,
                source = staging_table,
                insert_cols = quoted_source_columns,
                natural_key_col = strategy.natural_key
             )
          }}
      {% endcall %}

  {% endif %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}


{% macro scd2_history_strategy(node, config) %} -- change to config.require

    {% set natural_key_col = config['natural_key_col'] %}
    {% set backfill        = config['backfill'] if config['backfill'] else false %}

    {% if not natural_key_col %}
        {% do exceptions.raise_compiler_error("No value provided for 'natural_key_col' in config.") %}
    {% endif %}

    {% do return({
        "natural_key": natural_key_col,
        "backfill": backfill
    }) %}
{% endmacro %}

{% macro build_initial_scd2_history_table(strategy, sql) %}

  -- this is run when the target table is not found

  {% if strategy.backfill == false %}
    -- a full rebuild is done based on the full events table
    select  *,
          case
            when
              row_number()
              over (partition by {{ strategy.natural_key }} order by meta_start_time desc) = 1
                then 1
            else 0
          end as meta_is_latest
    from
    (
      select  *,
              ifnull(
                lead( d.meta_start_time)
                over (partition by {{ strategy.natural_key }} order by meta_start_time asc)
                , {{ CONSTANT_TIMESTAMP_BIG()}}) as meta_end_time
      from
      (
        {{ sql }}
      ) d
    )
    where meta_scd_action <> 'delete'

  {% else %} -- backfill

  select  *,
          case
            when
              row_number()
              over (partition by {{ strategy.natural_key }} order by meta_start_time desc) = 1
                then 1
            else 0
          end as meta_is_latest
  from
  (
    {{ sql }}
  ) d
  {% endif %}
{% endmacro %}


{% macro build_scd2_history_staging_table(strategy, sql, target_relation) %}
    {% set tmp_relation = make_temp_relation(target_relation) %}

    {% set new_rows_sql = scd2_history_staging_table_new_rows_sql(strategy, sql, target_relation) %}

    {% call statement('build_scd2_history_staging_relation_inserts') %}
        {{ create_table_as(True, tmp_relation, new_rows_sql) }}
    {% endcall %}

    {% do return(tmp_relation) %}
{% endmacro %}

{% macro scd2_history_staging_table_new_rows_sql(strategy, source_sql, target_relation) -%}

-- note here we only build history for the natrual keys that have change in this load partition
with natural_keys_changed as
(
  select  distinct
          {{ strategy.natural_key }}
  from
  (
  {{ sql }}
  ) a
  where meta_process_time = {{ meta_process_time() }}
)

select  *,
      case
        when
          row_number()
          over (partition by {{ strategy.natural_key }} order by meta_start_time desc) = 1
            then 1
        else 0
      end as meta_is_latest
from
(
    select  events.*,
            ifnull(
              lead( events.meta_start_time)
              over (partition by events.{{ strategy.natural_key }} order by events.meta_start_time asc)
              , {{ CONSTANT_TIMESTAMP_BIG()}}) as meta_end_time
    from
    (
      {{ sql }}
    ) events
    inner join natural_keys_changed changed
    on changed.{{ strategy.natural_key }} = events.{{ strategy.natural_key }}
  )
  where meta_scd_action <> 'delete'

{%- endmacro %}


{% macro scd2_history_merge_sql(target, source, insert_cols, natural_key_col) -%}
  {{ adapter.dispatch('scd2_history_merge_sql')(target, source, insert_cols, natural_key_col) }}
{%- endmacro %}

{% macro default__scd2_history_merge_sql(target, source, insert_cols, natural_key_col) -%}
  {%- set insert_cols_csv = insert_cols | join(', ') -%}

  -- this merge deletes rows that exist for the natural keys that have changed
  -- and inserts our newly calculated history
  merge {{ target }} trg

  -- we repeat the source set to allow us to trigger an insert and delete from the same set of source data
  using
  (
    select  'delete'                          as merge_operation,
            * except (meta_process_time),
            meta_process_time
    from    {{ source }}
    union all
    select  'insert'                          as merge_operation,
            * except (meta_process_time),
            {{ meta_process_time() }} as meta_process_time -- always load records in the current load partition
    from    {{ source }} a
  ) src
  on src.{{ natural_key_col }} = trg.{{ natural_key_col }} and src.merge_operation = 'delete'

  when matched then
    delete

  when not matched and merge_operation = 'insert' then
    insert({{ insert_cols_csv }}) values ({{ insert_cols_csv }})
{% endmacro %}
