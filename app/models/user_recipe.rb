class UserRecipe < ActiveRecord::Base

  belongs_to :user
  belongs_to :recipe

  def self.create(url, user)
    model = LibLinearModel.get_model
    recipe_document = RecipeDocument.new_document(:url => url)
    recipe = recipe_document.create_recipe(model)
    UserRecipe.new :recipe => recipe, :user => user
  end
end
