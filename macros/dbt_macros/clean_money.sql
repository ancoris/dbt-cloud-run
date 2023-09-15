------------------------------------------------------------------------------------------------------------------------
-- Author: TL
-- Parse SQLSERVER Money from String to Bignumeric. E.g '25,05,04' -> 2505.04
------------------------------------------------------------------------------------------------------------------------
{% macro clean_money(string) %}
    safe_cast(regexp_replace(left({{string}}, length({{string}}) - strpos(reverse({{string}}), ',')) || replace(right({{string}}, strpos(reverse({{string}}), ',')), ',', '.'), r'[^0-9.-]', '') as bignumeric)
{% endmacro %}