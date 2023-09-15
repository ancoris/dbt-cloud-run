{{
    config(
        materialized='table',
        schema='pl_reference_stage'
    )
}}

-- in this example we have an incremental source so the staging only represents changed records
select  id as cycle_station_natural_key,

        -- attributes
        installed,
        latitude,
        locked,
        longitude,
        name,
        bikes_count,
        docks_count,
        nbEmptyDocks,
        temporary,
        terminal_name,
        install_date,
        removal_date,

        -- meta fields
        meta_process_time,
        meta_delivery_time
from    {{ ref('cycle_stations_clean') }}
where   meta_process_time =  {{ meta_process_time() }}
