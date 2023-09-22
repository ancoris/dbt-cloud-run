FROM ghcr.io/dbt-labs/dbt-bigquery:1.5.6
USER root
WORKDIR /dbt
COPY . ./

RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir google-cloud-storage

ENTRYPOINT []
CMD ./.docker/dbt_job_commands.sh