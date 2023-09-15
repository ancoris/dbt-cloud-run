------------------------------------------------------------------------------------------------------------------------
-- Author: TL
-- Mimics BigQuery greatest function but ignore nulls. Must pass in array. e.g function('[a.col1, b.col2]')
------------------------------------------------------------------------------------------------------------------------
{% macro greatest_ignore_nulls(array) %}
   (select max(value) from unnest({{array}}) value where value is not null)
{% endmacro %}