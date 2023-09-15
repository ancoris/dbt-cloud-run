{% macro salt_hash(column, salt) %}
    {%- if not salt -%}
        {% set salt = ref.config.project_name %}
    {%- endif -%}

    to_hex(sha512(cast({{column}} as string) || cast('{{salt}}' as string)))
{% endmacro %}
