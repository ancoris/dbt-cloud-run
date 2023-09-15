{% macro null_if_only_whitespace(value) %}
  if({{value}} is not null and regexp_contains(cast({{value}} as string), r'\A\s*\z'), null, {{value}})
{% endmacro %}
