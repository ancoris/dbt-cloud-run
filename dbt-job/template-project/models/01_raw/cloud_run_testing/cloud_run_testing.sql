{{
    config(
        materialized = 'incremental',
        schema='bqpublic'
    )
}}

-- trivial commit

select 
         
  {% if is_incremental() %}
    (select max(id) from {{ this }}) +
  {% endif %}                
  1                       as id, 

  session_user()          as session_user,
  current_timestamp()     as current_timestamp,