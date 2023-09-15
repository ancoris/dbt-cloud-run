-- Convert civil/local time to civil/local. e.g Europe/London -> US/Eastern. Timezone names can be found here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. 

-- inputs:
-- column: datetime/timestamp
-- source_tz: string. Default: 'Europe/London'
-- target_tz: string. Default: 'Europe/London'

-- Outputs:
-- datetime

------------------------------------------------------------------------------------------------------------------------
{% macro tz_convert_timezone(column, source_tz, target_tz) %}
    {%- if not source_tz -%}
        {% set source_tz = 'Europe/London' %}
    {%- endif -%}

    {%- if not target_tz -%}
        {% set target_tz = 'Europe/London' %}
    {%- endif -%}

    {{tz_utc_to_local(tz_local_to_utc(column, source_tz), target_tz )}}
{% endmacro %}