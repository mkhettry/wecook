module UsersHelper

  def has_error(user, field)
    user.errors.any? && user.errors.messages.has_key?(field)
  end

  def class_for_form(user, field)
    class_name = "control-group"
    if has_error(user, field)
      class_name += " error"
    end
    class_name
  end

  def error_message_for_form(user, field)
    if has_error(user, field)
      user.errors.messages[field][0].capitalize
    end
  end
end
