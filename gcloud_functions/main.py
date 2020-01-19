import io
import os
import datetime
from google.oauth2 import service_account


from google.cloud import vision
from google.cloud import storage
from google.cloud import texttospeech

def download_blob(bucket_name, source_blob_name):
    """Downloads a blob from the bucket."""

    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(source_blob_name)
    buffer = io.BytesIO()
    return blob.download_to_file(buffer)

def upload_blob(bucket_name, source_file, destination_blob_name):
    """Uploads a file to the bucket."""
    # bucket_name = "your-bucket-name"
    # source_file_name = "local/path/to/file"
    # destination_blob_name = "storage-object-name"

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_file(source_file)

def generate_download_signed_url_v4(bucket_name, blob_name):
    """Generates a v4 signed URL for downloading a blob.

    Note that this method requires a service account key file. You can not use
    this if you are using Application Default Credentials from Google Compute
    Engine or from the Google Cloud SDK.
    """
    # bucket_name = 'your-bucket-name'
    # blob_name = 'your-object-name'

    # Set the credentials
    credentials = service_account.Credentials.from_service_account_file('credentials.json')

    storage_client = storage.Client(credentials=credentials)
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)

    url = blob.generate_signed_url(
        version="v4",
        # This URL is valid for 15 minutes
        expiration=datetime.timedelta(minutes=15),
        # Allow GET requests using this URL.
        method="GET",
    )

    print("Generated GET signed URL:")
    return url

def create_audio(input):
    # Instantiates a client
    client = texttospeech.TextToSpeechClient.from_service_account_file('credentials.json')

    # Set the text input to be synthesized
    synthesis_input = texttospeech.types.SynthesisInput(text=input)

    # Build the voice request, select the language code ("en-US") and the ssml
    # voice gender ("neutral")
    voice = texttospeech.types.VoiceSelectionParams(
        language_code='en-US',
        ssml_gender=texttospeech.enums.SsmlVoiceGender.NEUTRAL)

    # Select the type of audio file you want returned
    audio_config = texttospeech.types.AudioConfig(
        audio_encoding=texttospeech.enums.AudioEncoding.MP3)

    # Perform the text-to-speech request on the text input with the selected
    # voice parameters and audio file type
    response = client.synthesize_speech(synthesis_input, voice, audio_config)

    audio = io.BytesIO(response.audio_content)

    bucket_name = 'davishack.appspot.com'
    upload_blob(bucket_name, audio, 'lul.mp3')
    return generate_download_signed_url_v4(bucket_name, 'lul.mp3')

def analyse_image(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """

    image_uri = 'gs://davishack.appspot.com/p018.png'

    client = vision.ImageAnnotatorClient()
    image = vision.types.Image()
    image.source.image_uri = image_uri

    response = client.text_detection(image=image)

    final_text = ''
    for text in response.text_annotations:
        final_text += text.description

    return create_audio(final_text)