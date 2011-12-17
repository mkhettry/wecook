class Image < ActiveRecord::Base
  STYLES = {:medium => "330x330>", :thumb => "100x100>"}
  belongs_to :recipe
  before_create :set_styles

  if Rails.env.production?
    has_attached_file :jpg, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
      :styles => STYLES
  else
    has_attached_file :jpg, :styles => STYLES
  end

  # thumbnail and medium were introduced in dec 2011. remember that this image has styles so that for older
  # images we don't try to dereference styles that don't exit.
  def set_styles
    self.has_styles = true
  end
end
