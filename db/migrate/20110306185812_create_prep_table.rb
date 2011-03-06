class CreatePrepTable < ActiveRecord::Migration
  def self.up
    create_table :directions do |t|
      t.string :raw_text
      t.integer :recipe_id
    end
    remove_column :recipes, :prep
  end

  def self.down
    drop_table :directions
  end
end
