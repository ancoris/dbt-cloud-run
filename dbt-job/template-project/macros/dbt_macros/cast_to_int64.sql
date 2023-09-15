{% macro cast_to_int64(string) %}
    safe_cast(regexp_replace({{string}}, r'[^0-9.-]', '') as int64)
{% endmacro %}
