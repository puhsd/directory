class AddActiveToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :active, :boolean, default: true
    User.import_from_ldap
  end
  def down
    remove_column :users, :active, :boolean
  end


end
