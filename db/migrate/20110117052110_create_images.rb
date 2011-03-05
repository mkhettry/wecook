class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :recipe_id
      t.binary :contents

    end
  end

  def self.down
    drop_table :images
  end
end
