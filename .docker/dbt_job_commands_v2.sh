#!/bin/sh
cat .docker/dbt_job_commands.sh
dbt deps
dbt run -s cloud_run_testing --profiles-dir .