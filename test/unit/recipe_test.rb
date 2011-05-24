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
    recipe = create_provisional_recipe ["IN\ta", "OT\tb", "PR\tc", "OT\td"]
    recipe.correct! 1 => "IN"
    assert_equal 2, recipe.ingredients.length
    assert_equal 0, recipe.ingredients[0].ordinal
    assert_equal 1, recipe.ingredients[1].ordinal

  end

  private
  def create_provisional_recipe(lines)
    composite_line = ""
    lines.each do |line|
      composite_line += line
      composite_line += "\n"

    end
    Recipe.new(:page =>composite_line)
  end
end
