------------------------------------------------------------------------------------------------------------------------
-- Author: JGreen
-- This materialisation is used to build a kmeans ml model
------------------------------------------------------------------------------------------------------------------------
{% materialization ml_model_kmeans, default %}

{% set target_relation = this %}

-- 1. Build model
{% set build_model_sql %}
  create or replace model {{this.schema}}.{{this.name}}
  options( {{ model.config.model_options }} )
  as
  select  * except ({{model.config.feature_set_key}})
  from
  (
    {{sql}}
  );
{% endset %}

-- 2. Build model evaluation metrics
{% set build_evaluation_sql %}
  create or replace table {{this.schema}}.{{this.name | replace("_model","")}}_evaluation
  as
  select *
  from  ml.centroids(model {{this.schema}}.{{this.name}})
  order by centroid_id;
{% endset %}

-- 3. Build model training metrics
{% set build_training_sql %}
  create or replace table {{this.schema}}.{{this.name | replace("_model","")}}_training
  as
  select *
  from  ml.training_info(model {{this.schema}}.{{this.name}});
{% endset %}

-- 4. Build model output
{% set build_output_sql %}
  create or replace table {{this.schema}}.{{this.name | replace("_model","")}}_output
  as
  select  *
  from    ml.predict
          ( model {{this.schema}}.{{this.name}},
            (
              {{sql}}
            )
          );
{% endset %}

{% call statement("main") %}
    {{ build_model_sql }}
    {{ build_evaluation_sql }}
    {{ build_training_sql }}
    {{ build_output_sql }}
{% endcall %}

{{ run_hooks(post_hooks, inside_transaction=True) }}

{% do adapter.commit() %}

{{ run_hooks(post_hooks, inside_transaction=False) }}

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}
