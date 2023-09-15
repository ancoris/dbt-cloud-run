------------------------------------------------------------------------------------------------------------------------
-- Author: BSL
-- This materialisation is used to generate a federated table over a GCS bucket
------------------------------------------------------------------------------------------------------------------------
{% materialization from_gcs_csv, default %}

{% set target_relation = this %}

--this config item is REQUIRED for materialization run
{%- set source_uri = config.require('uris') -%}
{%- set unexpected_col_count = config.get('unexpected_col_count', default=0) -%}

{{ run_hooks(pre_hooks, inside_transaction=False) }}

-- `BEGIN` happens here:
{{ run_hooks(pre_hooks, inside_transaction=True) }}


-- 1. Main block
{% set main_sql_block %}
  create or replace external table {{this.database}}.{{this.schema}}.{{this.name}}
  (
    {{sql}}
  {% if unexpected_col_count > 0 %}
  {% for x in range(unexpected_col_count) %}
  unexpected_col_{{x+1}}      STRING,
  {%- endfor -%}
  {% endif %}
  )

  options
  (
    format = "csv"
    , uris = ["{{ source_uri }}"]
    , {{ model.config.options }}
  )
  ;
{% endset %}


{% call statement("main") %}
    {{ main_sql_block }}
{% endcall %}

{{ run_hooks(post_hooks, inside_transaction=True) }}

{% do adapter.commit() %}

{{ run_hooks(post_hooks, inside_transaction=False) }}

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}
