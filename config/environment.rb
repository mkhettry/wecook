# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cooks::Application.initialize!

unless Rails.env.production?
  Paperclip.options[:command_path] = "/opt/local/bin"
end
