{{
    config(
        materialized='incremental',
        schema='bqpublic',
        partition_by = {'field': 'date(meta_delivery_time)',
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
        {{meta_process_time() }} as meta_delivery_time
from {{ source('london_santander', 'cycle_stations') }}
where 1=1

{% if  is_incremental() %}

and ifnull(install_date, '2010-01-01') > (select ifnull(max(install_date), {{ CONSTANT_DATE_SMALL()}}) from {{ this }})

{% endif %}

and ifnull(install_date, '2010-01-01') < cast({{meta_process_time() }} as date)
