{% macro meta_process_time() %}

  {%- if model.config.materialized == 'view' -%}
    current_timestamp()
  {%- else -%}
    timestamp('{{ var("replay_process_time", run_started_at.isoformat()) }}')
  {%- endif -%}

{% endmacro %}
