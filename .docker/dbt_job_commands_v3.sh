#!/bin/sh
cat .docker/dbt_job_commands_v3.sh
dbt deps
dbt run -s cloud_run_testing --profiles-dir .
.docker/upload_artefacts.sh