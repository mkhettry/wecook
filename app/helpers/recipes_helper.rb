module RecipesHelper

  CATEGORY_MAP = {:Ingredients => "in", :Directions => "pr", :Other => "ot"}

  def get_class_for_inline_recipe(recipe)
    if recipe.is_ready?
      "recipeline"
    else
      "recipeline recipe_provisional"
    end
  end

  def get_title_link(recipe)
    if recipe.is_ready?
      link_to recipe.title, recipe, :remote => true
    else
      link_to recipe.title, show_provisional_recipe_path(recipe)
    end
  end

  def get_user_display_name
    user = current_user
    if user
      return user.name ? user.name : user.email
    end
  end
end
