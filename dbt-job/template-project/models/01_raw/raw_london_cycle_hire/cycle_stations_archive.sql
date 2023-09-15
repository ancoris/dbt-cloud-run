{{
    config(
        materialized='incremental',
        schema='archive_bqpublic',
        partition_by = {'field': 'date(meta_process_time)',
          'data_type':'date'}
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
        install_date,
        removal_date,

        -- meta fields
        {{meta_process_time() }} as meta_process_time,
        meta_delivery_time
from {{ ref('cycle_stations_raw') }}

-- we only load what has been delivered in this process window to simulate an incremental load
where meta_delivery_time = {{meta_process_time() }}
