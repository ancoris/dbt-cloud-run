------------------------------------------------------------------------------------------------------------------------
-- Author: BSL
-- Incremental models can now be tidier!
------------------------------------------------------------------------------------------------------------------------

{% macro generate_partition_dates(num_days_to_rebuild) %}

  {% set return_obj = [] %}
  {% for x in range(num_days_to_rebuild+1) %}
    {% set thing = 'date_sub(current_date, interval ' + x|string + ' day)'  %}
    {% do return_obj.append(thing) %}
  {% endfor %}

  {{ return(return_obj) }}

{% endmacro %}


{% macro generate_partition_timestamps(num_days_to_rebuild) %}

  {% set return_obj = [] %}
  {% for x in range(num_days_to_rebuild+1) %}
    {% set thing = 'timestamp(date_sub(current_date, interval ' + x|string + ' day))'  %}
    {% do return_obj.append(thing) %}
  {% endfor %}

  {{ return(return_obj) }}

{% endmacro %}



{% macro generate_partition_months(num_days_to_rebuild, date_fmt="") %}

  {% set return_obj = [] %}
  {% for x in range(num_days_to_rebuild+1) %}
    {% if date_fmt != '' %}
    {% set thing = 'format_date("' + date_fmt + '", date_sub(date_trunc(current_date, month), interval ' + x|string + ' month))'  %}
    {% else %}
    {% set thing = 'date_sub(date_trunc(current_date, month), interval ' + x|string + ' month)'  %}
    {% endif %}
    {% do return_obj.append(thing) %}
  {% endfor %}

  {{ return(return_obj) }}

{% endmacro %}