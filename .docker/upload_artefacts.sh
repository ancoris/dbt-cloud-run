#!/bin/sh

date=$(date +'%Y-%m-%dT%H:%M:%S')
#GCS_ARTIFACTS_BUCKET="data-sandbox-266217-misc-data" # delete before uploading

# graph.gpickle
gsutil cp target/graph.gpickle gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/latest/graph.gpickle
gsutil cp target/graph.gpickle gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/$date/graph.gpickle
echo "graph.gpickle uploaded successfully\n"

# manifest
gsutil cp target/manifest.json gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/latest/manifest.json
gsutil cp target/manifest.json gs://$GCS_ARTIFACTS_BUCKET/dbt_cloud_run/$CLOUD_RUN_JOB/$date/manifest.json
echo "manifest.json uploaded successfully\n"