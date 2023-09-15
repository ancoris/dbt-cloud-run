------------------------------------------------------------------------------------------------------------------------
-- Author: JGreen
-- This materialisation is used to build a linear regression ml model
------------------------------------------------------------------------------------------------------------------------
{% materialization ml_model_logistic_regression, default %}

{% set target_relation = this %}

-- 1. Build model
{% set build_model_sql %}
  create or replace model {{this.schema}}.{{this.name}}
  options( {{ model.config.model_options }} )
  as
  {{sql}};
{% endset %}

-- 2. Build roc curve
{% set build_roc_curve_sql %}

  create or replace view {{this.schema}}.{{this.name}}_roc_curve
  as
  select *
  from  ml.roc_curve(model {{this.schema}}.{{this.name}},
  (
    {{sql}}
  ));

{% endset %}

-- 3. Build model tuning metrics
{% set build_tuning_sql %}

  create or replace view {{this.schema}}.{{this.name}}_tuning
  as
  select  0.6               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.6) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.65               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.65) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.7               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.7) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.75               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.75) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.8               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.8) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.85               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.85) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.9               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.9) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  0.95               as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 0.95) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True'
  union all
  select  1                 as target_recall,
          threshold,
          recall,
          false_positive_rate,
          abs(recall - 1) as from_desired_recall
  from {{this.schema}}.{{this.name}}_roc_curve
  where is_train_day = 'True';
{% endset %}

{% call statement("main") %}
    {{ build_model_sql }}
{% endcall %}

{{ run_hooks(post_hooks, inside_transaction=True) }}

{% do adapter.commit() %}

{{ run_hooks(post_hooks, inside_transaction=False) }}

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}
