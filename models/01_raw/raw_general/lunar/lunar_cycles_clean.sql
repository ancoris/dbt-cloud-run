{{
    config(
        materialized='view',
        schema='clean_general'
    )
}}
select  full_moon_date,
        is_total_eclipse,
        is_partial_eclipse,
        region,
        meta_delivery_time,
        {{ meta_process_time() }}    as meta_process_time
  from  {{ref('lunar_cycles_dbt_seed')}}
