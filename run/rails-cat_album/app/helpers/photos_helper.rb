module PhotosHelper
  def image_url photo
    case Rails.application.config.active_storage.service
    when :local
      url_for photo.image
    when :google
      "https://storage.googleapis.com/#{ENV['STORAGE_BUCKET_NAME']}/#{photo.image.key}"
    end
  end
end
