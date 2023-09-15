-- This macro is used to generate the dataset name in which a model will be created
-- This copy existing overrides dbt's native macro
-- Delete/rename this macro to return to dbt's default behaviour

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- elif custom_schema_name[0] == "_" -%}

        _{{ default_schema }}_{{ custom_schema_name[1:] | trim }}

    {%- elif custom_schema_name == "force_to_dw_utils" -%}

        dw_utils

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
