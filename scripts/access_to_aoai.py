import urllib.request
import json
import os
import ssl
from dotenv import load_dotenv

def allowSelfSignedHttps(allowed):
    # bypass the server certificate verification on client side
    if allowed and not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None):
        ssl._create_default_https_context = ssl._create_unverified_context

allowSelfSignedHttps(True) # this line is needed if you use self-signed certificate in your scoring service.

# Request data goes here
# The example below assumes JSON formatting which may be updated
# depending on the format your endpoint expects.
# More information can be found here:
# https://docs.microsoft.com/azure/machine-learning/how-to-deploy-advanced-entry-script
data = {
    "messages": [
        {"role": "system", "content": [{"type": "text", "text": "情報を見つけるのに役立つ AI アシスタントです。"}]},
        {"role": "user", "content": [{"type": "text", "text": "Microsoftについて教えてください"}]},
    ],
    "temperature": 0.7,
    "top_p": 0.95,
    "frequency_penalty": 0,
    "presence_penalty": 0,
    "max_tokens": 800,
    "stop": None,
    "stream": True
}

body = str.encode(json.dumps(data))

# Load environment variables from .env file
load_dotenv()

api_key = os.getenv('AOAI_API_KEY')
base_url = os.getenv('AOAI_BASE_URL')
deployment_id = os.getenv('DEPLOYMENT_ID')
api_version = os.getenv('API_VERSION')
if not api_key:
    raise Exception("A key should be provided to invoke the endpoint")
if not base_url:
    raise Exception("A base URL should be provided to invoke the endpoint")
if not deployment_id:
    raise Exception("A deployment ID should be provided to invoke the endpoint")
if not api_version:
    raise Exception("An API version should be provided to invoke the endpoint")

url = f'{base_url}/{deployment_id}/chat/completions?api-version={api_version}'
headers = {
    'Content-Type':'application/json', 
    'Api-Key':api_key,
}

# Capture the HTTP request body before sending the request
print("HTTP request body:", body.decode('utf-8'))

req = urllib.request.Request(url, body, headers)

try:
    response = urllib.request.urlopen(req)

    # Read and concatenate the content from the response
    content = ""
    for line in response:
        if line:
            chunk = line.decode('utf-8').strip()
            if chunk.startswith("data: "):
                chunk = chunk[6:]  # Remove the "data: " prefix
            if chunk:  # Ensure chunk is not empty
                try:
                    line_data = json.loads(chunk)
                    if 'choices' in line_data:
                        for choice in line_data['choices']:
                            if 'delta' in choice and 'content' in choice['delta']:
                                content_piece = choice['delta']['content']
                                print(content_piece, end='')  # Print each piece without a newline
                except json.JSONDecodeError:
                    print("Failed to decode JSON chunk:", chunk)
except urllib.error.HTTPError as error:
    print("The request failed with status code: " + str(error.code))

    # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
    print(error.info())
    print(error.read().decode("utf8", 'ignore'))
