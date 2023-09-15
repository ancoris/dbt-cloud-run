------------------------------------------------------------------------------------------------------------------------
-- Author: JGreen
-- This materialisation is used to maintain static tables such as a date dimension.
-- The materialisation will only refresh the target on initial creation and in full-refresh-mode.
-- No action is taken on an incremental run.
------------------------------------------------------------------------------------------------------------------------
{% materialization static_table, default -%}

  {% set full_refresh_mode = flags.FULL_REFRESH %}


  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}


  {{ run_hooks(pre_hooks, inside_transaction=False) }}
  {{ run_hooks(pre_hooks, inside_transaction=True) }}


  {% if existing_relation is none or existing_relation.is_view or full_refresh_mode %}
      {% set build_sql = create_table_as(False, target_relation, sql) %}
  {% else %} -- must be an incremental run
      {% set build_sql = 'select 1' %} --we need a valid SQL statement here
  {% endif %}


  {% call statement("main") %}
      {{ build_sql }}
  {% endcall %}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {% do adapter.commit() %}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}
{%- endmaterialization %}
