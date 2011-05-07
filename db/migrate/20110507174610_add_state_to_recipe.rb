class AddStateToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :state, :string
  end

  def self.down
    remove_column :recipes, :state
  end
end
