#!/bin/sh
cat .docker/dbt_job_commands.sh
ls
realpath .docker/dbt_job_commands.sh
dbt deps
dbt seed
dbt run --profiles-dir .