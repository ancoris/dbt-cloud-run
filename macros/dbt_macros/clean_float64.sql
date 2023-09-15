{% macro clean_float64(value, safe_cast=true) %}
    {%- if safe_cast -%}
        safe_cast(regexp_replace(cast({{value}} as string), r'[^0-9.-]', '') as float64)

    {%- else -%}
        cast(regexp_replace(cast({{value}} as string), r'[^0-9.-]', '') as float64)
    
    {%- endif -%}
{% endmacro %}
