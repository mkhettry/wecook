class AddEntirePageToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :page, :text
  end

  def self.down
    remove_column :recipes, :page
  end
end
