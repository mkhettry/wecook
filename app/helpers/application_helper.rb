module ApplicationHelper
  def get_link_class(choice, params_p)
    if ((current_page?(recipes_path) || current_page?(root_path)) &&
        params_p.nil? &&
        choice == :mine)
      return "active"
    elsif (current_page?(recipes_path) && !params_p.nil? && choice == :all)
      return "active"
    elsif (current_page?(new_recipe_path) && choice == :add)
      return "active"
    end
    ""
  end
end
