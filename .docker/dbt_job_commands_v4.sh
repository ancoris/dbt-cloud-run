#!/bin/sh
cat .docker/dbt_job_commands_v4.sh
dbt deps
dbt run -s cloud_run_testing --profiles-dir .
python .docker/upload_artefacts.py