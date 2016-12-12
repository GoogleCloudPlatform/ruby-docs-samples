<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Vision API Ruby Samples

The [Cloud Vision API][vision_docs] allows developers to easily integrate vision
detection features within applications, including image labeling, face and
landmark detection, optical character recognition (OCR), and tagging of explicit
content.

[vision_docs]: https://cloud.google.com/vision/docs/

## Run sample

To run the sample, first install dependencies:

    bundle install

If you haven't already, configure default credentials for using the
[Cloud SDK](https://cloud.google.com/sdk/):

    gcloud auth login
    gcloud init

Next, set the configured project by setting the *GOOGLE_CLOUD_PROJECT*
environment variable to the project name set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"


### Run the labels detection sample:

    bundle exec ruby detect_labels.rb images/cat.jpg

### Run the landmark detection sample:

    bundle exec ruby detect_landmarks.rb images/eiffel_tower.jpg 

### Run the face detection sample:

    bundle exec ruby detect_faces.rb images/face.png output-image.jpg    
