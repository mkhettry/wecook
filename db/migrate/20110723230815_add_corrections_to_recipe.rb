class AddCorrectionsToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :corrections, :string, :length => 255, :default => ""
  end

  def self.down
    remove_column :recipes, :corrections
  end
end
