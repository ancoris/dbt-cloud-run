{{
    config(
        materialized='scd2_history',
        schema='pl_reference',
        natural_key_col='cycle_station_natural_key'
    )
}}
select  cycle_station_surrogate_key,
        cycle_station_natural_key,

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
        meta_delivery_time,
        meta_scd_action,
        meta_start_time
from  {{ ref('dim_cycle_station_events') }}
