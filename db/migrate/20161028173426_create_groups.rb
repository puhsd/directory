class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :object_guid
      t.string :dn
      t.string :displayname
      t.string :samaccountname
      t.string :mail
      t.string :grouptype
      t.timestamp :ldap_imported_at

      t.timestamps
    end
    add_index :groups, :object_guid, :unique => true
    add_index :groups, :dn, :unique => true
  end
end
