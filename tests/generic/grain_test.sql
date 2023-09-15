{% test grain_test(model, column_name, grain_columns) %}

  select
    {% for col in grain_columns -%}
    {{ col }}{% if not loop.last %},{% endif %}
    {% endfor -%}
  from {{ model }}
  group by
    {% for col in grain_columns -%}
    {{ col }}{% if not loop.last %},{% endif %}
    {% endfor -%}
  having count(*) > 1

{% endtest %}
