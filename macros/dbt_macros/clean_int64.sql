{% macro clean_int64(value, safe_cast=true) %}
    {%- if safe_cast -%}
        safe_cast(regexp_replace(cast({{value}} as string), r'[^0-9.-]', '') as int64)

    {%- else -%}
        cast(regexp_replace(cast({{value}} as string), r'[^0-9.-]', '') as int64)
    
    {%- endif -%}
{% endmacro %}