class AddPrepToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :prep, :text
  end

  def self.down
    remove_column :recipes, :prep
  end
end
