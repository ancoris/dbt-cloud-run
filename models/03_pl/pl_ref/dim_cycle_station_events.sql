{{
  config(
      materialized='scd2_events',
      mode= 'incremental',
      schema='pl_reference',
      check_cols=[
      'installed',
      'latitude',
      'locked',
      'longitude',
      'name',
      'bikes_count',
      'docks_count',
      'nbEmptyDocks',
      'temporary',
      'terminal_name',
      'install_date',
      'removal_date'
      ],

      natural_key_col='cycle_station_natural_key',
      modified_time='meta_process_time',
      created_time='install_date',
      partition_by = {'field': 'date(meta_process_time)',
        'data_type':'date'}
  )
}}
select  cycle_station_natural_key,

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
from    {{ ref('dim_cycle_station_stage') }}
where   meta_process_time =  {{ meta_process_time() }}
