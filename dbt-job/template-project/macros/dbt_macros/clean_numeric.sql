{% macro clean_numeric(value, safe_cast=true) %}
    {%- if safe_cast -%}
        safe_cast(regexp_replace(cast({{value}} as string), r'[^0-9.-]', '') as numeric)

    {%- else -%}
        cast(regexp_replace(cast({{value}} as string), r'[^0-9.-]', '') as numeric)
    
    {%- endif -%}
{% endmacro %}
