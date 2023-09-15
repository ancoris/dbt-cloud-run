-- Convert civil/local time to UTC. Timezone names can be found here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. 

-- inputs:
-- column: datetime/timestamp
-- tz: string. Default: 'Europe/London'

-- Outputs:
-- timestamp

------------------------------------------------------------------------------------------------------------------------
{% macro tz_local_to_utc(column, tz) %}
    {%- if not tz -%}
        {% set tz = 'Europe/London' %}
    {%- endif -%}
    timestamp(datetime({{column}}), '{{tz}}')
{% endmacro %}