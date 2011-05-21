class AddLogin < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string
    add_column :users, :password_hash, :string
    add_column :users, :password_salt, :string
  end

  def self.down
    remove_column :users, :email
    remove_column :users, :password_hash
    remove_column :users, :password_salt
  end
end
