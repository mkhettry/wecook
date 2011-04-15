require 'test_helper'

class FeatureSelectorTest < ActiveSupport::TestCase

  setup do
    @class_under_test = FeatureSelector.new
    @water = Feature.new("water")
    @boil = Feature.new("boil")
    @cook = Feature.new("cook")
    @word2 = Feature.new("2")
    @word2_another = Feature.new("2")
  end


  test "category count updates" do
    @class_under_test.update(:IN, [])
    @class_under_test.update(:IN, [])
    @class_under_test.update(:PR, [])
    assert_equal({:IN => 2, :PR => 1}, @class_under_test.category_counts.category_counts)
  end

  test "category count for feature updates" do
    @class_under_test.update(:IN, [@water, @boil])
    @class_under_test.update(:IN, [@cook, @water])
    @class_under_test.update(:PR, [@word2, @water])
    @class_under_test.update(:PR, [@word2_another, @cook])

    assert_equal({:IN => 2, :PR => 1}, @class_under_test.category_counts_for_feature[@water].category_counts)
    assert_equal({:PR => 2}, @class_under_test.category_counts_for_feature[@word2_another].category_counts)
    assert_equal({:PR => 2}, @class_under_test.category_counts_for_feature[@word2].category_counts)
    assert_equal({:IN => 1}, @class_under_test.category_counts_for_feature[@boil].category_counts)
    assert_equal({:IN => 1, :PR => 1}, @class_under_test.category_counts_for_feature[@cook].category_counts)
  end



end