class AddStateToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :state, :string
    Recipe.update_all("state = 'ready'")
  end

  def self.down
    remove_column :recipes, :state
  end
end
