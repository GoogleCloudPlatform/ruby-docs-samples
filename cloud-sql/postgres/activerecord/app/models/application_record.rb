class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.find_database
    if ENV['INSTANCE_UNIX_HOST']
      return "#{Rails.env}_unix".to_sym
    end
    if ENV['INSTANCE_HOST']
      return "#{Rails.env}_tcp".to_sym
    end
  end

  establish_connection find_database
end
