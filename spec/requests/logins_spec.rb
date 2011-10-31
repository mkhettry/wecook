require 'spec_helper'


describe "Logins" do

  def remove_user(name = "me")
    user = User.find_by_name(name)
    user.destroy if user
  end

  describe "create user" do
    it "create native user that does not exist successfully" do
      remove_user

      visit new_user_path

      fill_in "user_name", :with => "me"
      fill_in "user_email", :with => "me@m"
      fill_in "user_password", :with => "test"
      fill_in "user_password_confirmation", :with => "test"

      click_button "user_submit"

      page.should have_content "Hello, me"

      # Is it a good idea to mix direct model assets in integration tests like this?
      User.find_by_name("me").provider.should == "native"
    end
  end
end
