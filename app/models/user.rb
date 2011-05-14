class User < ActiveRecord::Base

  has_many :user_recipes, :dependent => :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.name = auth["user_info"]["name"]
      user.uid = auth["uid"]
    end
  end
end
