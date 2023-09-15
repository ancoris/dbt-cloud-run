{% macro safe_concat(field_list, separator) %}

  {# Takes an input list and generates a concat() statement with each argument in the list safe_casted to a string and wrapped in an ifnull() #}
  {# Can optionally pass a separator, defaults to '' #}
  {#{{ safe_concat(['column_name1', 'column_name2'], '_')}} #}

    {%- if not separator -%}
        {% set separator = '' %}
    {%- endif -%}

    concat(
        {% for f in field_list %}
            ifnull(safe_cast({{ f }} as string), '')
        
        {% if not loop.last %}
        || '{{ separator }}' ,
        {% endif %}

        {% endfor %}
    )
{% endmacro %}
