class AddNeedsProvisionalHelpToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :needs_prov_help, :boolean, :default => true
    User.update_all("needs_prov_help = 'true'")
  end

  def self.down
    remove_column :users, :needs_prov_help
  end
end
