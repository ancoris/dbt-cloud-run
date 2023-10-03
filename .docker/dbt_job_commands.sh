#!/bin/sh
cat .docker/dbt_job_commands.sh
dbt deps
dbt debug
dbt source freshness
dbt seed
dbt run --profiles-dir .
dbt test
python .docker/upload_artefacts.py