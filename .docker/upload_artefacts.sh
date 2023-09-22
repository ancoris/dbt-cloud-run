#!/bin/sh

# debugging
date=$(date +'%Y-%m-%dT%H:%M:%S')
GCS_ARTIFACTS_BUCKET="data-sandbox-266217-misc-data" # delete before uploading
CLOUD_RUN_JOB="dbt-job3"

echo "date="$date
echo "GCS_ARTIFACTS_BUCKET="$GCS_ARTIFACTS_BUCKET
echo "CLOUD_RUN_JOB="$CLOUD_RUN_JOB

# graph.gpickle
gcloud storage cp target/graph.gpickle gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/latest/graph.gpickle
gcloud storage cp target/graph.gpickle gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/$date/graph.gpickle
echo "graph.gpickle uploaded successfully\n"

# manifest
gcloud storage cp target/manifest.json gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/latest/manifest.json
gcloud storage cp target/manifest.json gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/$date/manifest.json
echo "manifest.json uploaded successfully\n"