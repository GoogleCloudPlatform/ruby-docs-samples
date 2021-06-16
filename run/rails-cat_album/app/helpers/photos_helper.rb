module PhotosHelper
  def image_url photo
    case Rails.application.config.active_storage.service
    when :local
      url_for photo.image
    when :google
      "https://storage.googleapis.com/cat_album_storage/#{photo.image.key}"
    end
  end
end
