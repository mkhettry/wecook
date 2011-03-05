class Image < ActiveRecord::Base
  belongs_to :recipe
  has_attached_file :jpg 
end
