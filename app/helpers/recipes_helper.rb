module RecipesHelper

  CATEGORY_MAP = {:Ingredients => "in", :Directions => "pr", :Other => "ot"}
  REVERSE_CATEGORY_MAP = {"in" => "Ingredient", "pr" => "Direction", "ot" => "Other"}

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

  def time_string(date)
    recipe_save_time = date.localtime
    day_number = Time.now.yday
    if (recipe_save_time.yday == day_number)
      "Today"
    elsif (day_number - date.yday == 1)
      "Yesterday"
    else
      recipe_save_time.strftime("%b %d, %Y")
    end
  end

  def get_link_class(choice, params_p)
    "rindex-left-nav-highlight" if choice.to_s == params_p || (choice == :mine && params_p.nil?)
  end
end
