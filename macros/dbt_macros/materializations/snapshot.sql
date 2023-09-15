------------------------------------------------------------------------------------------------------------------------
-- Author: JGreen
-- This materialisation is used to build a periodic snapshot over an existing fact table
------------------------------------------------------------------------------------------------------------------------
{% materialization snapshot, default -%}
  {% set config         = model['config'] -%}
  {% set partition_by   = config['partition_by'] %}
  {% set cluster_by     = config['cluster_by'] %}
  {% set snapshots      = config['snapshots'] %}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set offset = 0 %}
  {% set sql_run = sql | replace('snapshot_offset', 0) %}

  {% call statement('create', fetch_result=True) %}
      create or replace table {{this}}
      partition by {{partition_by}}
      cluster by {{cluster_by}}
      as
      {{sql_run}}
  {% endcall %}

  {% for offset in range(1, snapshots)%}
    {% set sql_run = sql | replace('snapshot_offset', offset) %}
    {% call statement('insert', fetch_result=True) %}
      insert into {{this}}
      {{sql_run}}
    {% endcall %}
  {% endfor %}

  {% set build_sql = 'select 1' %} --we need a valid SQL statement here
  {% call statement("main") %}
      {{ build_sql }}
  {% endcall %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {% do adapter.commit() %}

  {{ run_hooks(post_hooks, inside_transaction=False) }}
{%- endmaterialization %}
