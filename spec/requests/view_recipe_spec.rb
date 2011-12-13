require "spec_helper"
require "rspec_utils"

describe "recipe viewing" do

  def create_recipe_for_user(url, file)
    r = Recipe.get_or_create_recipe("file://spec/fixtures/webpages/#{file}\##{url}")
    r.correct!("")
    r.save

    ur = UserRecipe.create(r.url, @user)
    ur.save
    ur
  end

  before(:all) do
    @user = ensure_user_exists EMAIL
  end

  it "should open ready recipe on click", :js => true do
    login_as_user EMAIL

    create_recipe_for_user("http://evolvingtastes.blogspot.com/2009/12/shevayachi-kheer.html",
                  "evolving_tastes.html")

    visit recipes_path
    #save_and_open_page

    first_inline_recipe = page.first(:css, "div.inline_recipe")
    first_inline_recipe.should_not be_visible

    page.first(:css, "div.recipetitle").first('a').click

    #puts "***** first_inline_recipe=#{first_inline_recipe.inspect}"

    #save_and_open_page
    first_inline_recipe = page.first(:css, "div.inline_recipe")
    first_inline_recipe.should be_visible

    first_inline_recipe.should have_css("div.ingredient_and_prep")
    sections = first_inline_recipe.all(:css, "div.section_header")
    sections.size.should == 2

    # now click the link again
    page.first(:css, "div.recipetitle").first('a').click

    first_inline_recipe = page.first(:css, "div.inline_recipe")
    first_inline_recipe.should_not be_visible

  end

  pending "should show other peoples recipes for all recipes" do

  end

end