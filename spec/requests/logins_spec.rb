require 'spec_helper'


describe "Logins" do

  describe "create user" do

    def fill_form(user, email, password, password_confirmation)
      fill_in "user_name", :with => user
      fill_in "user_email", :with => email
      fill_in "user_password", :with => password
      fill_in "user_password_confirmation", :with => password_confirmation
    end

    def submit_form
      click_button "Join"
    end

    it "create native user that does not exist successfully" do
      visit new_user_path
      fill_form("me", "me@m", "test", "test")
      submit_form
      page.should have_content "me"
      page.should have_content "Sign Out"

      # Is it a good idea to mix direct model assets in integration tests like this?
      User.find_by_name("me").provider.should == "native"
    end

    it "does not create native user when password does not match" do
      visit new_user_path

      fill_form("me", "me@m", "pw", "pw2")
      submit_form
      current_path.should == "/users"
      page.should have_content "Doesn't match confirmation"
    end

    it "does not create user when email exists" do
      User.create! :name => "w", :email => "me@m", :password => "m", :provider => "native"

      visit new_user_path

      fill_form("me", "me@m", "test", "test")
      submit_form

      current_path.should == "/users"
      page.should have_content "Has already been taken"
    end
  end
end
