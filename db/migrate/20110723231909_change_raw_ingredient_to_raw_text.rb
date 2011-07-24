class ChangeRawIngredientToRawText < ActiveRecord::Migration
  def self.up
    rename_column :ingredients, :raw, :raw_text
  end

  def self.down
    rename_column :ingredients, :raw_text, :raw
  end
end
