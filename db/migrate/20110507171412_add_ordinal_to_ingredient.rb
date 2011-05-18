class AddOrdinalToIngredient < ActiveRecord::Migration
  def self.up
    add_column :ingredients, :ordinal, :integer
  end

  def self.down
    remove_column :ingredients, :ordinal
  end
end
