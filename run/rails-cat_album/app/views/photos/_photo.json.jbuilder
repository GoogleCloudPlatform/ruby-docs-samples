json.extract! photo, :id, :caption, :created_at, :updated_at
json.url photo_url(photo, format: :json)
