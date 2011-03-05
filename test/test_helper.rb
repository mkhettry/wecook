ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_lines(array, lines)
    i=0
    assert_equal array.length, lines.length, "length mismatch"
    puts array.length
    lines.each do |line|
      assert_equal array[i], line, "error in line #{i}"
      i += 1
    end
  end

end
