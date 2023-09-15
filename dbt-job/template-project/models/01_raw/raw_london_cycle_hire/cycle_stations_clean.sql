{{
    config(
        materialized='view',
        schema='clean_bqpublic'
    )
}}
select  id,
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
        ifnull(install_date, '2010-01-01') as install_date,
        removal_date,

        -- meta fields
        meta_process_time,
        meta_delivery_time
from {{ ref('cycle_stations_archive') }}
