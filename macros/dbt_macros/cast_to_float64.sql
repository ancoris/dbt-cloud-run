{% macro cast_to_float64(float64) %}
  safe_cast(regexp_replace(cast({{float64}} as string), r'[^0-9.-]', '') as float64)
{% endmacro %}
