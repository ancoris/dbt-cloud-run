from httplib2 import Http
from oauth2client.service_account import ServiceAccountCredentials
from apiclient.discovery import build

import base64   # pub/sub events are base64 encoded
import json     # parse json objects (event received from pub/sub)
import ast      # parse not-quite-json objects
import re       # detect success/fail from policy name

# Import the Secret Manager client library.
from google.cloud import secretmanager
import google_crc32c


def base64_to_json_obj(base64_encoded_string, key_to_pull=None):

  if key_to_pull:
    # Pull data value out from event
    data = ast.literal_eval(base64_encoded_string)[key_to_pull]
  else:
    data = ast.literal_eval(base64_encoded_string)

  # converting the base64 code into ascii characters
  convertbytes = data.encode("ascii")
  
  # converting into bytes from base64 system
  convertedbytes = base64.b64decode(convertbytes)

  # decoding the ASCII characters into alphabets
  decodedsample = convertedbytes.decode("ascii")

  # This is now ready to load as a json, then pull out what I need.
  json_obj = json.loads(decodedsample)

  return json_obj


def success_status_helper(event_incident_policy_name):
  # Detect whether run was a success or fail. Protect against non-exact policy names.
  l = event_incident_policy_name.lower()

  if re.search(r'succe', l):
    success_or_fail = "Succeeded"
  elif re.search(r'fail', l):
    success_or_fail = "Failed"
  else:
    success_or_fail = "Success status unknown"

  return success_or_fail


def notif_body_constructor(job_name="Job name not found", success_or_fail="Failed", project_id="Project ID not found"):
  if success_or_fail == "Succeeded":
    status_colour = "#80e27e"
  else:
    status_colour = "#d60000"

  body = \
  {
    'cardsV2': [{
      'cardId': 'createCardMessage',
      'card': {
        'sections': [
          {
            'widgets': [
              {
                "textParagraph": {
                  "text": f"<b><font color=\"{status_colour}\">{success_or_fail}</font></b> \n Job name: {job_name} \n Project id: {project_id}"
                }
              },
              {
                "divider": {}
              },
              {
                  "columns": {
                    "columnItems": [
                        {
                          "horizontalSizeStyle": "FILL_AVAILABLE_SPACE",
                          'widgets': [
                            {
                              "textParagraph": {
                                "text": "Job History"
                              }
                            },
                            {
                              "textParagraph": {
                                "text": "Logs"
                              }
                            }
                            ]
                        },
                        { 
                          "horizontalSizeStyle": "FILL_MINIMUM_SPACE",
                          'widgets': [
                            {
                              'buttonList': {
                                'buttons': [
                                  {
                                    'text': 'Open',
                                    'onClick': {
                                      'openLink': {
                                        'url': f'https://console.cloud.google.com/run/jobs/details/europe-west2/{job_name}/executions'
                                      }
                                    }
                                  }
                                ]
                              }
                            },
                            {
                              'buttonList': {
                                'buttons': [
                                  {
                                    'text': 'Open',
                                    'onClick': {
                                      'openLink': {
                                        'url': f'https://console.cloud.google.com/run/jobs/details/europe-west2/{job_name}/logs'
                                  }
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  ]
                }
              }
            ]
          }
        ]
      }             
    }]
  }


  return body


def access_secret_version(
    project_id: str, secret_id: str, version_id: str
) -> secretmanager.AccessSecretVersionResponse:
    """
    Access the payload for the given secret version if one exists. The version
    can be a version number as a string (e.g. "5") or an alias (e.g. "latest").
    """

    # Import the Secret Manager client library.
    from google.cloud import secretmanager

    # Create the Secret Manager client.
    client = secretmanager.SecretManagerServiceClient()

    # Build the resource name of the secret version.
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"

    # Access the secret version.
    response = client.access_secret_version(request={"name": name})

    # Verify payload checksum.
    crc32c = google_crc32c.Checksum()
    crc32c.update(response.payload.data)
    if response.payload.data_crc32c != int(crc32c.hexdigest(), 16):
        print("Data corruption detected.")
        return response

    # Print the secret payload.
    #
    # WARNING: Do not print the secret in a production environment - this
    # snippet is showing how to access the secret material.
    payload = response.payload.data.decode("UTF-8")
    payload = json.loads(payload)
    return payload


def main(event, context):
  ## decode the event
  event_json = base64_to_json_obj(base64_encoded_string=str(event), key_to_pull="data")

  # create dict to allow variable space_id from centralised function
  # Update this if/when we deploy to other projects
  space_id_dict = {
    "data-sandbox-266217": "AAAAozoILB4",
    "cfolab-rubik": "AAAAg6MT-6I",
    "data_casual_space": "AAAASr6cU6U",
    "data_&_AI_space": "AAAAx8pPxz4"}

  # Pull out useful info
  event_incident_policy_name = event_json["incident"]["policy_name"]
  event_incident_resource_label_job_name = event_json["incident"]["resource"]["labels"]["job_name"]
  event_json_incident_resource_labels_project_id = event_json["incident"]["resource"]["labels"]["project_id"]
  success_or_fail = success_status_helper(event_incident_policy_name)

  # Specify required scopes.
  scopes = ['https://www.googleapis.com/auth/chat.bot']

  # Specify service account details.
  svc_acc_keyfile = access_secret_version(
    project_id="data-shared-assets",
    secret_id="google_chat_notifier_keyfile",
    version_id="latest")
  
  credentials = ServiceAccountCredentials.from_json_keyfile_dict(
      svc_acc_keyfile, scopes)

  # Build the URI and authenticate with the service account.
  chat = build('chat', 'v1', http=credentials.authorize(Http()))

  # Construct the body of the chat message.
  body = notif_body_constructor(
    job_name=event_incident_resource_label_job_name,
    success_or_fail=success_or_fail,
    project_id=event_json_incident_resource_labels_project_id) 

  # Which space are we sending to?
  # Pull out from dict based on project_id
  parent = f'spaces/{space_id_dict[event_json_incident_resource_labels_project_id]}'

  # send the message
  result = chat.spaces().messages().create(
    parent=parent,
    body=body
  ).execute()

  print(result)

 

event_example = """
{'data': 'ewogICJpbmNpZGVudCI6IHsKICAgICJjb25kaXRpb24iOiB7CiAgICAgICJjb25kaXRpb25NYXRjaGVkTG9nIjogewogICAgICAgICJmaWx0ZXIiOiAicmVzb3VyY2UudHlwZT1cImNsb3VkX3J1bl9qb2JcIlxucmVzb3VyY2UubGFiZWxzLmxvY2F0aW9uPVwiZXVyb3BlLXdlc3QyXCJcbnJlc291cmNlLmxhYmVscy5wcm9qZWN0X2lkPVwiZGF0YS1zYW5kYm94LTI2NjIxN1wiXG5wcm90b1BheWxvYWQuc3RhdHVzLm1lc3NhZ2U9flwiY29tcGxldGVkIHN1Y2Nlc3NmdWxseS4kXCJcbnByb3RvUGF5bG9hZC5zdGF0dXMubWVzc2FnZT1+XCJeRXhlY3V0aW9uXCIiCiAgICAgIH0sCiAgICAgICJkaXNwbGF5TmFtZSI6ICJMb2cgbWF0Y2ggY29uZGl0aW9uIiwKICAgICAgIm5hbWUiOiAicHJvamVjdHMvZGF0YS1zYW5kYm94LTI2NjIxNy9hbGVydFBvbGljaWVzLzcwNjE5MTM2NjU3NzgxMDc2ODAvY29uZGl0aW9ucy83MDYxOTEzNjY1Nzc4MTEwMjkzIgogICAgfSwKICAgICJjb25kaXRpb25fbmFtZSI6ICJMb2cgbWF0Y2ggY29uZGl0aW9uIiwKICAgICJlbmRlZF9hdCI6IG51bGwsCiAgICAiaW5jaWRlbnRfaWQiOiAiMC5uMzFqZGZ0eGc0bWsiLAogICAgIm1ldGFkYXRhIjogewogICAgICAic3lzdGVtX2xhYmVscyI6IHt9LAogICAgICAidXNlcl9sYWJlbHMiOiB7fQogICAgfSwKICAgICJtZXRyaWMiOiB7CiAgICAgICJkaXNwbGF5TmFtZSI6ICIiLAogICAgICAibGFiZWxzIjoge30sCiAgICAgICJ0eXBlIjogIiIKICAgIH0sCiAgICAicG9saWN5X25hbWUiOiAiQ2xvdWQgUnVuIEpvYiBTdWNjZXNzIiwKICAgICJyZXNvdXJjZSI6IHsKICAgICAgImxhYmVscyI6IHsKICAgICAgICAiam9iX25hbWUiOiAiZGJ0LWpvYjMiLAogICAgICAgICJsb2NhdGlvbiI6ICJldXJvcGUtd2VzdDIiLAogICAgICAgICJwcm9qZWN0X2lkIjogImRhdGEtc2FuZGJveC0yNjYyMTciCiAgICAgIH0sCiAgICAgICJ0eXBlIjogImNsb3VkX3J1bl9qb2IiCiAgICB9LAogICAgInJlc291cmNlX2lkIjogIiIsCiAgICAicmVzb3VyY2VfbmFtZSI6ICJDbG91ZCBSdW4gSm9iIGxhYmVscyB7am9iX25hbWU9ZGJ0LWpvYjMsIGxvY2F0aW9uPWV1cm9wZS13ZXN0MiwgcHJvamVjdF9pZD1kYXRhLXNhbmRib3gtMjY2MjE3fSIsCiAgICAicmVzb3VyY2VfdHlwZV9kaXNwbGF5X25hbWUiOiAiQ2xvdWQgUnVuIEpvYiIsCiAgICAic2NvcGluZ19wcm9qZWN0X2lkIjogImRhdGEtc2FuZGJveC0yNjYyMTciLAogICAgInNjb3BpbmdfcHJvamVjdF9udW1iZXIiOiA0Njg1NjA2NjE4NzksCiAgICAic3RhcnRlZF9hdCI6IDE2OTY1MDMzNDAsCiAgICAic3RhdGUiOiAib3BlbiIsCiAgICAic3VtbWFyeSI6ICJMb2cgbWF0Y2ggY29uZGl0aW9uIGZpcmVkIGZvciBDbG91ZCBSdW4gSm9iIHdpdGgge2pvYl9uYW1lPWRidC1qb2IzLCBsb2NhdGlvbj1ldXJvcGUtd2VzdDIsIHByb2plY3RfaWQ9ZGF0YS1zYW5kYm94LTI2NjIxN30uIiwKICAgICJ1cmwiOiAiaHR0cHM6Ly9jb25zb2xlLmNsb3VkLmdvb2dsZS5jb20vbW9uaXRvcmluZy9hbGVydGluZy9pbmNpZGVudHMvMC5uMzFqZGZ0eGc0bWs/cHJvamVjdD1kYXRhLXNhbmRib3gtMjY2MjE3IgogIH0sCiAgInZlcnNpb24iOiAiMS4yIgp9', 'message_id': '8581348713455038', 'publish_time': '2023-10-05T15:06:55.396Z'}
"""

context_example = """
"{event_id: 8581512461832556, timestamp: 2023-10-05T10:55:40.785Z, event_type: google.pubsub.topic.publish, resource: {'service': 'pubsub.googleapis.com', 'name': 'projects/data-sandbox-266217/topics/cloud_run_success', 'type': 'type.googleapis.com/google.pubsub.v1.PubsubMessage'}}"
"""

if __name__ == "__main__": 
  main(event_example, context_example)