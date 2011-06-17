class User < ActiveRecord::Base

  has_many :user_recipes, :dependent => :destroy

  attr_accessor :password
  before_save :encrypt_password

  validates :password, :presence =>true, :confirmation => true, :on => :create, :if => :is_native?
  validates :email, :presence => true, :uniqueness => {:scope => :uid}, :on => :create, :if => :is_native?
  validates :provider, :inclusion => {:in => ["native", "facebook"]}

  def is_native?
    self.provider == "native"
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
    self.provider = "native"
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.name = auth["user_info"]["name"]
      user.uid = auth["uid"]
    end
  end
end
