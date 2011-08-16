require "spec_helper"

describe "RecipesHelper" do
  include RecipesHelper

  describe "get tag" do
    it "should parse single tag" do
      get_tags('t.co/recipes?tag=summer').should == ['summer']
    end

    it "should parse multiple tags" do
      get_tags('t.co/recipes?tag=summer,salad').should == ['summer', 'salad']
    end
  end

  describe "remove tags" do
    it "should remove only tag" do
      remove_tag('t.co/recipes?tag=summer', 'summer').should == 't.co/recipes?'
    end

    it "should remove one of multiple tags" do
      remove_tag('t.co/recipes?tag=summer,salad,yogurt', 'salad').should == 't.co/recipes?tag=summer%2Cyogurt'
    end

    it "should also remove any page param" do
      remove_tag('t.co/recipes?page=2&tag=summer', 'summer').should == 't.co/recipes?'
    end
  end
end
