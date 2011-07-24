class AddStructuredToRecipes < ActiveRecord::Migration
  def self.up
    add_column :recipes, :structured, :boolean
    Recipe.update_all("structured = 'true'")
  end

  def self.down
    remove_column :recipes, :structured
  end
end
