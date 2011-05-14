class Image < ActiveRecord::Base
  belongs_to :recipe
  if Rails.env.production?
    has_attached_file :jpg, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml"
  else
    has_attached_file :jpg
  end
end
