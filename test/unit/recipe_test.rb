require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  fixtures(:recipes)

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
    correction_string = "1=IN|3=PR"
    recipe.correct! correction_string
    assert_equal 2, recipe.ingredients.length
    assert_equal 0, recipe.ingredients[0].ordinal
    assert_equal 1, recipe.ingredients[1].ordinal
    assert_equal "a", recipe.ingredients[0].raw_text
    assert_equal "b", recipe.ingredients[1].raw_text

    assert_equal 2, recipe.directions.length
    assert_equal "c", recipe.directions[0].raw_text
    assert_equal "d", recipe.directions[1].raw_text

    assert_equal "|" + correction_string, recipe.corrections
  end


  test "correct provisional recipe second time" do
    recipe = create_provisional_recipe ["IN\ta", "OT\tb", "PR\tc", "OT\td", "OT\te"]

    puts recipe.corrections
    puts recipe

    recipe.correct! "1=PR"
    recipe.correct! "3=IN"

    assert_equal 2, recipe.ingredients.length
    assert_equal 0, recipe.ingredients[0].ordinal
    assert_equal 1, recipe.ingredients[1].ordinal
    assert_equal "a", recipe.ingredients[0].raw_text
    assert_equal "d", recipe.ingredients[1].raw_text

    assert_equal 2, recipe.directions.length
    assert_equal "b", recipe.directions[0].raw_text
    assert_equal "c", recipe.directions[1].raw_text

    assert_equal "|1=PR|3=IN", recipe.corrections
  end

  test "get or create fetches from database" do
    r = Recipe.get_or_create_recipe(recipes(:google).url)
    assert_equal true, r.persisted?
    assert_equal recipes(:google)['id'], r['id']
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
