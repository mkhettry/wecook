
require "spec_helper"

describe "UserRecipe" do

  fixtures :users, :recipes

  it "finds recipes for user" do
    (1..25).each do |i|
      Recipe.create! :url => "url_#{i}", :title => "title_#{i}"
      UserRecipe.create("url_#{i}", users(:user2)).save
    end
    user2_recipes = UserRecipe.find_page_for_user({:page => 1, :order => "created_at desc"}, users(:user2).id)

    user2_recipes.length.should == UserRecipe.per_page
    user2_recipes.each do |ur|
      ur.user_id.should == users(:user2).id
    end
  end

  it "reuses persisted user recipe" do
    user2_google = UserRecipe.create(recipes(:google).url, users(:user2))
    user2_google.should_not be_persisted
    user2_google.save
    user2_google.should be_persisted
  end

  it "updates modified time if user saves same recipe" do
    user2_google = UserRecipe.create(recipes(:google).url, users(:user2))
    user2_google.save
    first_updated_at = user2_google.updated_at

    user2_google = UserRecipe.create(recipes(:google).url, users(:user2))
    user2_google.save
    assert user2_google.updated_at.should > first_updated_at
  end

end