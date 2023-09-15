#!/bin/sh
cat dbt_job_commands.sh
dbt deps
dbt seed
dbt run --profiles-dir .

