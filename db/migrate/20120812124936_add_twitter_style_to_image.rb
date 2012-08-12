class AddTwitterStyleToImage < ActiveRecord::Migration
  def change
    add_column :images, :twitter_style, :boolean
  end
end
