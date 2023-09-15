FROM ghcr.io/dbt-labs/dbt-bigquery:1.5.6
USER root
WORKDIR /dbt
COPY .docker/dbt_job_commands.sh ./
COPY * ./
COPY . ./

ENTRYPOINT "./dbt_job_commands.sh" 