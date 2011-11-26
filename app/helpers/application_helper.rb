module ApplicationHelper
  def get_link_class(choice, params_p)
    "welcome_nav_link_highlighted" if choice.to_s == params_p || (choice == :mine && params_p.nil?)
  end

end
