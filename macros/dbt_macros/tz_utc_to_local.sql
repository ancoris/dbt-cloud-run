-- Convert UTC to civil/local time. Timezone names can be found here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. 

-- inputs:
-- column: timestamp
-- tz: string. Default: 'Europe/London'

-- Outputs:
-- datetime

------------------------------------------------------------------------------------------------------------------------
{% macro tz_utc_to_local(column, tz) %}
    {%- if not tz -%}
        {% set tz = 'Europe/London' %}
    {%- endif -%}
    datetime(timestamp({{column}}), '{{tz}}')
{% endmacro %}