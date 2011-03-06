class ChangeDirection < ActiveRecord::Migration
  def self.up
    change_column :directions, :raw_text, :text
  end

  def self.down
    change_column :directions, :raw_text, :string
  end
end
