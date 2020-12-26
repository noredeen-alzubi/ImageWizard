json.extract! image, :id, :created_at, :updated_at, :picture_url
json.url image_url(image, format: :json)
