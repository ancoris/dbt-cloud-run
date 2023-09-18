FROM ghcr.io/dbt-labs/dbt-bigquery:1.5.6
USER root
WORKDIR /dbt
COPY . ./

ENTRYPOINT "./.docker/dbt_job_commands.sh" 