------------------------------------------------------------------------------------------------------------------------
-- Author: BSL
-- This materialization sends the contents directly to the database with no modifications.
-- Useful when you want to avoid dbt interfering with a quick query.
------------------------------------------------------------------------------------------------------------------------
{% materialization materialization_none, default -%}

  {% set full_refresh_mode = flags.FULL_REFRESH %}

  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}
  {{ run_hooks(pre_hooks, inside_transaction=True) }}


  {% call statement("main") %}
      {{ sql }}
  {% endcall %}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {% do adapter.commit() %}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}
{%- endmaterialization %}
