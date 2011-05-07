module RecipesHelper

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

  def get_lines_with_prediction(recipe)
    out = []
    recipe.page.split("\n").each do |line|
      parts = line.split("\t")
      out << {:class => "pr_"+parts[0].downcase, :line => parts[1]}
    end
    out
  end


end
