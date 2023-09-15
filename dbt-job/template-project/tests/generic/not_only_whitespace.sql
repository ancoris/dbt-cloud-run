{% test not_only_whitespace(model, column_name) %}

    select column_name
    from {{ model }}
    where {{ column_name }} is not null and regexp_contains(cast({{ column_name }} as string), r'\A\s*\z')

{% endtest %}