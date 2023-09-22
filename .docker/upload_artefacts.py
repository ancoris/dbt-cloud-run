import datetime
import os
from google.cloud import storage


# debugging only
# Set environment variables
#os.environ['GCS_ARTIFACTS_BUCKET'] = 'data-sandbox-266217-misc-data'
#os.environ['CLOUD_RUN_JOB'] = 'dbt-job3'

dt = datetime.datetime.now().replace(microsecond=0).isoformat()

# Get environment variables
gcs_artifacts_bucket = os.getenv('GCS_ARTIFACTS_BUCKET')
cloud_run_job = os.environ.get('CLOUD_RUN_JOB')



print("date=" + dt)
print("gcs_artifacts_bucket=" + gcs_artifacts_bucket)
print("cloud_run_job=" + cloud_run_job)


from google.cloud import storage


def upload_blob(bucket_name, source_file_name, destination_blob_name):
    """Uploads a file to the bucket."""
    # The ID of your GCS bucket
    # bucket_name = "your-bucket-name"
    # The path to your file to upload
    # source_file_name = "local/path/to/file"
    # The ID of your GCS object
    # destination_blob_name = "storage-object-name"

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)


    blob.upload_from_filename(source_file_name)

    print(
        f"File {source_file_name} uploaded to {destination_blob_name}."
    )


upload_blob(gcs_artifacts_bucket, 'target/graph.gpickle', 'dbt_cloud_run/' + cloud_run_job + '/latest/graph.gpickle')
upload_blob(gcs_artifacts_bucket, 'target/graph.gpickle', 'dbt_cloud_run/' + cloud_run_job + '/' + dt + '/graph.gpickle')

upload_blob(gcs_artifacts_bucket, 'target/manifest.json', 'dbt_cloud_run/' + cloud_run_job + '/latest/manifest.json')
upload_blob(gcs_artifacts_bucket, 'target/manifest.json', 'dbt_cloud_run/' + cloud_run_job + '/' + dt + '/manifest.json')


# ß
# # graph.gpickle
# gcloud storage cp target/graph.gpickle gs://gcs_artifacts_bucket/dbt_cloud_run/$CLOUD_RUN_JOB/latest/graph.gpickle
# gcloud storage cp target/graph.gpickle gs://gcs_artifacts_bucket/dbt_cloud_run/$CLOUD_RUN_JOB/$date/graph.gpickle
# echo "graph.gpickle uploaded successfully\n"
# 
# # manifest
# gcloud storage cp target/manifest.json gs://gcs_artifacts_bucket/dbt_cloud_run/$CLOUD_RUN_JOB/latest/manifest.json
# gcloud storage cp target/manifest.json gs://gcs_artifacts_bucket/dbt_cloud_run/$CLOUD_RUN_JOB/$date/manifest.json
# echo "manifest.json uploaded successfully\n"