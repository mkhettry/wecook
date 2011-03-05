class AddRecipeToIngredient < ActiveRecord::Migration
  def self.up
    add_column :ingredients, :recipe_id, :integer
  end

  def self.down
    remove_column :ingredients, :recipe_id
  end
end
