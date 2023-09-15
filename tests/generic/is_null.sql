{% test is_null(model, column_name) %}

with validation as (
  select
    {{ column_name }} as null_field
  from {{ model }}
),

validation_errors as (
  select
    null_field
  from validation
  -- if this is true, then null_field is actually populated!
  where null_field is not null
)

select *
from validation_errors

{% endtest %}
