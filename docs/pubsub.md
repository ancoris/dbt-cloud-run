# Pub/Sub triggered service

So far, we deployed HTTP triggered public services. However, this is not the only way to trigger Cloud Run services. In this tutorial, let's see how a Cloud Pub/Sub message can trigger an internal service. You can read more about this in Cloud Run [docs](https://cloud.google.com/run/docs/events/pubsub-push).

![Cloud Run with Pub/Sub](./images/cloud-run-pubsub.png)

## Create a 'Event Display' service

Take a look at the service we already created in [event-display](../event-display) folder. It simply logs out the HTTP request body. We'll use it to display the received messages.

## Build the container

In folder where `Dockerfile` resides, build the container using Cloud Build and push it to Container Registry:

```sh
PROJECT_ID=$(gcloud config get-value project)
SERVICE_NAME=event-display

gcloud builds submit \
  --tag gcr.io/$PROJECT_ID/$SERVICE_NAME
```

## Deploy to Cloud Run

Note that we're deploying with `no-allow-unauthenticated` flag. We only want Pub/Sub to trigger the service:

```sh
REGION=us-central1

gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/event-display \
  --no-allow-unauthenticated \
  --platform managed \
  --region $REGION 
```

## Setup Pub/Sub to trigger Cloud Run

Create a Pub/Sub topic:

```sh
TOPIC_NAME=cloudrun-pubsub

gcloud pubsub topics create $TOPIC_NAME
```

Create a service account:

```sh
SERVICE_ACCOUNT=$TOPIC_NAME-sa

gcloud iam service-accounts create $SERVICE_ACCOUNT \
   --display-name "Cloud Run Pub/Sub Service Account"
```

Give service account permission to invoke the Cloud Run service:

```sh
gcloud run services add-iam-policy-binding $SERVICE_NAME \
   --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
   --role=roles/run.invoker \
   --platform managed
```

Enable your project to create Cloud Pub/Sub authentication tokens:

```sh
gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
     --role=roles/iam.serviceAccountTokenCreator
```

Create a Cloud Pub/Sub subscription with the service account:

```sh
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')

gcloud pubsub subscriptions create $TOPIC_NAME-subscription --topic $TOPIC_NAME \
   --push-endpoint=$SERVICE_URL \
   --push-auth-service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
```

## Test the service

You can test the service by sending a message to the queue:

```sh
gcloud pubsub topics publish $TOPIC_NAME --message "Hello World"
```

If you check the logs of the service in Cloud Run console, you should see the event:

```sh
Event Display received event: {"message":{"data":"SGVsbG8gV29ybGQ=","messageId":"849662793093263","message_id":"849662793093263","publishTime":"2019-11-12T16:12:51.296Z","publish_time":"2019-11-12T16:12:51.296Z"},"subscription":"projects/knative-atamel/subscriptions/cloudrun-topic-subscription"}
```

The message is base64 encoded under data:

```sh
echo SGVsbG8gV29ybGQ= | base64 -D

Hello World
```
