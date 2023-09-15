------------------------------------------------------------------------------------------------------------------------
-- Author: TL
-- Mimics BigQuery least function but ignore nulls. Must pass in array. e.g function('[a.col1, b.col2]')
------------------------------------------------------------------------------------------------------------------------
{% macro least_ignore_nulls(array) %}
   (select min(value) from unnest({{array}}) value where value is not null)
{% endmacro %}