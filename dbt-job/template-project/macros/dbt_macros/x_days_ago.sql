{% macro x_days_ago(no_of_days) %}

  {% set today = modules.datetime.date.today() %}
  {% set delta_days = modules.datetime.timedelta(days=no_of_days) %}
  {% set requested_date = (today - delta_days) %}

  {{ return(requested_date) }}

{% endmacro %}
