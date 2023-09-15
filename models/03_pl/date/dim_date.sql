{{
    config(
        materialized = 'static_table',
        schema='pl_reference',
    )
}}
with date_dimension as (
    {{ date_dimension('1900-01-01', '2050-12-31') }}
)
select  *
from    date_dimension
