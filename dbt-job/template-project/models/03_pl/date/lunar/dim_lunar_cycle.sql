{{
    config(
        materialized='static_table',
        schema='pl_reference'
    )
}}
with first_full_moon_on_or_after_21_march as
(
  select region,
         extract(year from full_moon_date)  as year,
         min(full_moon_date)                as min_full_moon_date
  from  {{ref('lunar_cycles_clean')}}
  where full_moon_date >= cast(concat(extract(year from full_moon_date), '-03-21') as date)
  group by region, year
)

select  c.full_moon_date,
        c.is_total_eclipse,
        c.is_partial_eclipse,
        c.region,
        if(f.year is not null,1,0)              as is_first_full_moon_on_or_after_march_21,

        -- meta
        meta_delivery_time,
        meta_process_time
from    {{ref('lunar_cycles_clean')}} c
  left outer join first_full_moon_on_or_after_21_march f
  on f.region = c.region
  and f.year = extract(year from c.full_moon_date)
  and f.min_full_moon_date = c.full_moon_date
