{{
    config(
        materialized='view',
        schema='clean_bqpublic'
    )
}}
select  rental_id,
        duration,
        bike_id,
        end_date,
        end_station_id,
        end_station_name,
        start_date,
        start_station_id,
        start_station_name,
        end_station_logical_terminal,
        start_station_logical_terminal,
        end_station_priority_id,

        -- meta fields
        meta_process_time,
        meta_delivery_time
from {{ ref('cycle_hire_archive') }}
