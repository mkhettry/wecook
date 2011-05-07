module RecipesHelper

  def get_class_for_inline_recipe(recipe)
    if recipe.is_ready?
      "recipeline"
    else
      "recipeline recipe_provisional"
    end
  end

end
