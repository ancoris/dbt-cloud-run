{{
    config(
        materialized='incremental',
        schema='raw_bqpublic',
        partition_by = {'field': 'date(meta_delivery_time)',
          'data_type':'date'}
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
        {{meta_process_time() }} as meta_delivery_time
from {{ source('london_santander', 'cycle_hire') }}
where 1=1

{% if is_incremental() %}

and start_date > (select ifnull(max(start_date), {{ CONSTANT_TIMESTAMP_SMALL()}}) from {{ this }})

{% endif %}

and start_date < {{meta_process_time() }}

limit 100 -- MAKE SURE YOU REMOVE THIS! ONLY FOR TEMPLATE PURPOSES.
