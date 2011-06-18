require "spec_helper"

describe "UserRecipe" do

  fixtures :users, :recipes

  it "finds recipes for user" do
    (1..15).each do |i|
      Recipe.create! :url => "url_#{i}", :title => "title_#{i}"
      UserRecipe.create("url_#{i}", users(:srinidhi)).save
    end
    sri_recipes = UserRecipe.find_page_for_user({:page => 1, :order => "created_at desc"}, users(:srinidhi).id)

    sri_recipes.length.should == 1000
    sri_recipes.each do |ur|
      ur.user_id.should == users(:srinidhi).id
    end
  end

  it "reuses persisted user recipe" do
    sri_google = UserRecipe.create(recipes(:google).url, users(:srinidhi))
    sri_google.should_not be_persisted
    sri_google.save
    sri_google.should be_persisted
  end

end