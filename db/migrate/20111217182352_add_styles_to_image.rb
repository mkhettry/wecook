class AddStylesToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :has_styles, :boolean
  end

  def self.down
    remove_column :images, :has_styles
  end
end
