from httplib2 import Http
from oauth2client.service_account import ServiceAccountCredentials
from apiclient.discovery import build

# Specify required scopes.
SCOPES = ['https://www.googleapis.com/auth/chat.bot']

# Specify service account details.
CREDENTIALS = ServiceAccountCredentials.from_json_keyfile_name(
    'credentials_v2.json', SCOPES)

# Build the URI and authenticate with the service account.
chat = build('chat', 'v1', http=CREDENTIALS.authorize(Http()))

# Create a Chat message.
result = chat.spaces().messages().create(

    # The space to create the message in.
    #
    # Replace SPACE_NAME with a space name.
    # Obtain the space name from the spaces resource of Chat API,
    # or from a space's URL.
    parent='spaces/AAAAozoILB4',

    # The message to create.
    body={'text': 'Nice to meet you too'}

).execute()

# Prints details about the created message.
print(result)