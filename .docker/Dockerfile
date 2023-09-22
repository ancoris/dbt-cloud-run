FROM ghcr.io/dbt-labs/dbt-bigquery:1.5.6
RUN apt-get install google-cloud-sdk dumb-init -y
USER root
WORKDIR /dbt
COPY . ./

ENTRYPOINT []
CMD ./.docker/dbt_job_commands.sh