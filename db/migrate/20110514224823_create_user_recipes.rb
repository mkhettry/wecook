class CreateUserRecipes < ActiveRecord::Migration
  def self.up
    create_table :user_recipes do |t|
      t.integer :user_id
      t.integer :recipe_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_recipes
  end
end
