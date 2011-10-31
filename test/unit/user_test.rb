require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures(:users)

  test "native user validation missing password and email" do
    user = User.new
    user.provider = "native"
    assert user.invalid?
    assert_equal ["can't be blank"], user.errors[:password]
    assert_equal ["can't be blank"], user.errors[:email]
  end


  test "native user validation  missing password" do
    user = User.new
    user.provider = "native"
    user.email = 'manish@yahoo.com'
    assert user.invalid?
    assert_equal ["can't be blank"], user.errors[:password]
    assert !user.errors[:email].any?
  end

  test "native user validation all is good" do
    user = User.new
    user.provider = "native"
    user.email = 'manish@yahoo.com'
    user.password = 'test'
    assert user.valid?, "native user with email/password should be valid"
  end

  test "native user duplicate email" do
    user = User.new
    user.provider = "native"
    user.email = 'manish@yahoo.com'
    user.password = 'test'
    user.save

    user2 = User.new
    user2.provider = "native"
    user2.email = 'manish@yahoo.com'
    user2.password = 'test'

    assert !user2.valid?, "user2 should not be valid"
    assert_equal user2.errors[:email], ["has already been taken"]
  end

  test "facebook user" do
    user = User.new
    user.provider = "facebook"
    user.uid = 'abc'
    user.name = 'manish khettry'
    assert user.valid?, "facebook user without email/password should be valid."
  end

  test "create with omniauth" do
    auth = {"provider" => "facebook", "user_info" => {"name" => "testname"}, "uid" => '241'}
    user = User.create_with_omniauth(auth)
  end


  test "unknown provider" do
    user = User.new
    user.provider = "twitter"
    user.name = 'manish khettry'
    assert !user.valid?, "unknown provider"
  end

  test "create with omni auth" do
    auth = {"provider" => "facebook", "uid" => "100", "user_info" => {"name" => "foobar"}}
    User.create_with_omniauth auth
    user = User.find_by_provider_and_uid("facebook", auth["uid"])
    assert !user.nil?
  end

end
