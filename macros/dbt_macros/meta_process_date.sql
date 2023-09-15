{% macro meta_process_date() %}

  {%- if model.config.materialized == 'view' -%}
    current_date()
  {%- else -%}
    date('{{ var("replay_process_time", run_started_at.isoformat()) }}')
  {%- endif -%}

{% endmacro %}
