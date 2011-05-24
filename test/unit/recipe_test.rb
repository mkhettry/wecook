require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  test "site_source" do
    {"http://www.101cookbooks.com/archives/spring-pasta-recipe.html" => "101cookbooks.com",
     "http://www.foodnetwork.com/recipes/alton-brown/chicken-kiev-recipe/index.html" => "foodnetwork.com"
    }.each_pair do |k, v|
      r = Recipe.new(:url => k)
      assert_equal v, r.site_source
    end
  end

  test "correct provisional recipe" do

  end
end
