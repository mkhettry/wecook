class Image < ActiveRecord::Base
  STYLES = {:medium => "330x330#", :thumb => "260x180#"}
  belongs_to :recipe
  before_create :set_styles

  if Rails.env.production?
    has_attached_file :jpg,
                      :storage => :s3,
                      :bucket => "wecook-production-us",
                      :s3_credentials => {
                          :access_key_id => ENV['S3_KEY'],
                          :secret_access_key => ENV['S3_SECRET']
                      },
                      :styles => STYLES
  else
    has_attached_file :jpg, :styles => STYLES
  end

  # thumbnail and medium were introduced in dec 2011. remember that this image has styles so that for older
  # images we don't try to dereference styles that don't exist.
  # twitter style was introduced in may/june 2012 and changed the thumb style to be larger.
  def set_styles
    self.has_styles = true
    self.twitter_style = true
  end
end
