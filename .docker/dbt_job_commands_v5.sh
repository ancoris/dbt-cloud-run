#!/bin/sh
cat .docker/dbt_job_commands_v5.sh
dbt deps
dbt run -s cloud_run_testing --profiles-dir .
