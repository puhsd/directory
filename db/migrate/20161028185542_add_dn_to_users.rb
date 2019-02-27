class AddDnToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :distinguishedname, :string
    # User.import_from_ldap
    add_index :users, :distinguishedname, :unique => true
  end

  def down
    remove_column :users, :distinguishedname, :string
  end
end
