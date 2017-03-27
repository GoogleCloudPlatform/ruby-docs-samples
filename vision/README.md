<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Vision API Ruby Samples

The [Cloud Vision API][vision_docs] allows developers to easily integrate vision
detection features within applications, including image labeling, face and
landmark detection, optical character recognition (OCR), and tagging of explicit
content.

[vision_docs]: https://cloud.google.com/vision/docs/

[Vision How-to Guides](https://cloud.google.com/vision/docs/how-to)

## Run samples

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

## Samples

### Detect Crop Hints

    Usage: ruby detect_crop_hints.rb [image file path]

    Example:
      ruby detect_crop_hints.rb image.png
      ruby detect_crop_hints.rb https://public-url/image.png
      ruby detect_crop_hints.rb gs://my-bucket/image.png

### Detect Document Text
 
    Usage: ruby detect_document_text.rb [image file path]

    Example:
      ruby detect_document_text.rb image.png
      ruby detect_document_text.rb https://public-url/image.png
      ruby detect_document_text.rb gs://my-bucket/image.png

### Detect Faces
     
    Usage: ruby detect_faces.rb [image file path]

    Example:
      ruby detect_faces.rb image.png
      ruby detect_faces.rb https://public-url/image.png
      ruby detect_faces.rb gs://my-bucket/image.png

### Detect Image Properties
     
    Usage: ruby detect_image_properties.rb [image file path]

    Example:
      ruby detect_image_properties.rb image.png
      ruby detect_image_properties.rb https://public-url/image.png
      ruby detect_image_properties.rb gs://my-bucket/image.png

### Detect Labels
     
    Usage: ruby detect_labels.rb [image file path]

    Example:
      ruby detect_labels.rb image.png
      ruby detect_labels.rb https://public-url/image.png
      ruby detect_labels.rb gs://my-bucket/image.png

### Detect Landmarks
     
    Usage: ruby detect_landmarks.rb [image file path]

    Example:
      ruby detect_landmarks.rb image.png
      ruby detect_landmarks.rb https://public-url/image.png
      ruby detect_landmarks.rb gs://my-bucket/image.png

### Detect Logos
     
    Usage: ruby detect_logos.rb [image file path]

    Example:
      ruby detect_logos.rb image.png
      ruby detect_logos.rb https://public-url/image.png
      ruby detect_logos.rb gs://my-bucket/image.png

### Detect Safe Search Properties
     
    Usage: ruby detect_safe_search.rb [image file path]

    Example:
      ruby detect_safe_search.rb image.png
      ruby detect_safe_search.rb https://public-url/image.png
      ruby detect_safe_search.rb gs://my-bucket/image.png

### Detect Text
     
    Usage: ruby detect_text.rb [image file path]

    Example:
      ruby detect_text.rb image.png
      ruby detect_text.rb https://public-url/image.png
      ruby detect_text.rb gs://my-bucket/image.png

### Detect Web Entities and Pages
     
    Usage: ruby detect_web.rb [image file path]

    Example:
      ruby detect_web.rb image.png
      ruby detect_web.rb https://public-url/image.png
      ruby detect_web.rb gs://my-bucket/image.png
