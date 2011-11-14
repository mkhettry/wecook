require 'spec_helper'

EMAIL = "int_test@localhost"

describe "create recipes" do

  before(:each) do
    ensure_user_exists EMAIL
    login_as_user EMAIL
  end

  def ensure_user_exists(email)
    user = User.find_by_email(email)
    unless user
      User.create!(:email => EMAIL, :provider => "native", :password => "test")
    end
  end

  def login_as_user(email)
    visit welcome_path
    #save_and_open_page
    fill_in "email", :with => email
    fill_in "password", :with => "test"
    click_button "Sign in"
  end

  def add_recipe(url, file)
    visit new_recipe_path
    #save_and_open_page
    fill_in "recipe_url", :with => "file://spec/fixtures/webpages/#{file}\##{url}"
    click_button "recipe_submit"
  end


  def title_should_be(first_recipe, title_text)
    title = first_recipe.find(:css, "div.recipetitle")
    title.text.should == title_text
  end


  it "should create unstructured recipe" do
    add_recipe "http://evolvingtastes.blogspot.com/2009/12/shevayachi-kheer.html", "evolving_tastes.html"

    current_path.should == "/recipes"

    # TODO:figure out how to wrap this up nicely so that we can say
    #   first_recipe.should be provisional?
    #   first_recipe.should have_title "...."
    # or something along these lines
    first_recipe = page.first(:css, "div.recipeline")
    first_recipe[:class].should match /recipe_provisional/

    title_should_be first_recipe, "Evolving Tastes: Shevayachi Kheer"

    meta = first_recipe.find(:css, "div.recipemeta")
    meta.text.should match /\bevolvingtastes.blogspot.com\b/
    meta.text.should match /\bToday\b/

    actual_link = meta.find("a")
    actual_link[:href].should == "http://evolvingtastes.blogspot.com/2009/12/shevayachi-kheer.html"

    inline_recipes = page.all(:css, "div.inline_recipe")
    inline_recipes.each do |ir|
      ir.should_not be_visible
    end
  end

  it "should create structured recipe" do
    url = "http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954"
    file = "Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html"

    add_recipe url, file

    first_recipe = page.first(:css, "div.recipeline")
    first_recipe[:class].should_not match /recipe_provisional/

    title_should_be first_recipe, "Swiss Chard Lasagna with Ricotta and Mushroom Recipe  at Epicurious.com"
  end
end
