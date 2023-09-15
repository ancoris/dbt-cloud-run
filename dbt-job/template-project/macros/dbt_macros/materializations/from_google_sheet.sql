------------------------------------------------------------------------------------------------------------------------
-- Author: BSL
-- This materialisation is used to generate a federated table from a google sheet
------------------------------------------------------------------------------------------------------------------------
{% materialization from_google_sheet, default %}

{% set target_relation = this %}

--this config item is REQUIRED for materialization run
{%- set source_uri = config.require('uris') -%}

{{ run_hooks(pre_hooks, inside_transaction=False) }}

-- `BEGIN` happens here:
{{ run_hooks(pre_hooks, inside_transaction=True) }}

-- 1. Main block
{% set main_sql_block %}
  create or replace external table {{this.database}}.{{this.schema}}.{{this.name}}
  (
    {{sql}}
  )

  options
  (
    format = "GOOGLE_SHEETS"
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
