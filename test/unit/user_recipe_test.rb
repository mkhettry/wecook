require 'test_helper'
class UserRecipeTest < ActiveSupport::TestCase
  fixtures :recipes, :users

  test "only one recipe per user " do
    sri_google = UserRecipe.create(recipes(:google).url, users(:srinidhi))
    assert_equal false, sri_google.persisted?
    sri_google.save

    assert_equal true, UserRecipe.create(recipes(:google).url, users(:srinidhi)).persisted?
    assert_equal false, UserRecipe.create(recipes(:google).url, users(:manish)).persisted?
  end
end