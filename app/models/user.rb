class User < ActiveRecord::Base

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.name = auth["user_info"]["name"]
      user.uid = auth["uid"]
    end
  end
end
