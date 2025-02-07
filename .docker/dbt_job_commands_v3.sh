#!/bin/sh
cat .docker/dbt_job_commands_v3.sh
echo $GCS_ARTIFACTS_BUCKET
echo $CLOUD_RUN_JOB
dbt deps
dbt run -s cloud_run_testing --profiles-dir .
python .docker/upload_artefacts.py