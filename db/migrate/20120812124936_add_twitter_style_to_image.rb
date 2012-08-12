class AddTwitterStyleToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :twitter_style, :boolean
  end

  def self.down
    remove_column :images, :twitter_style
  end
end
