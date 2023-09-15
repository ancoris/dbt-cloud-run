{{
    config(
        materialized='materialization_none',
        schema='force_to_dw_utils',
        enabled=false
    )
}}

-- This can be created elsewhere, kept within dbt for simplicity
-- All inserts handled by cloud function

create table if not exists {{ this.database }}.{{this.schema}}.{{this.name}} (cloud_function STRING, error_time STRING, error STRING)
