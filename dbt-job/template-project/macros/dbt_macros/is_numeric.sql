------------------------------------------------------------------------------------------------------------------------
-- Author: TL
-- Mimics SQLSERVER ISNUMERIC function. This function tests if an expression is numeric, returns true if so, false otherwise.
-- This can be used alongside clean_numeric macro. e.g is_numeric(clean_numeric(value))
------------------------------------------------------------------------------------------------------------------------

{% macro is_numeric(value) %}
  safe_cast({{value}} as numeric) is not null
{% endmacro %}
