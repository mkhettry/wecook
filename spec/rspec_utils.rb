
EMAIL = "int_test@localhost"

def ensure_user_exists(email)
  user = User.find_by_email(email)
  if user
    user
  else
    User.create!(:email => EMAIL, :provider => "native", :password => "test")
  end

end

def login_as_user(email)
  visit welcome_path
  #save_and_open_page
  fill_in "email", :with => email
  fill_in "password", :with => "test"
  click_button "Sign in"
end
