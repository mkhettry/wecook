class AddTitleToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :title, :string, {:null => false}
  end

  def self.down
    remove_column :recipes, :title
  end
end
