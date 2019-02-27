class CreateUsers < ActiveRecord::Migration[5.2]
  def change
  	enable_extension "hstore"
    create_table :users do |t|
      t.string :object_guid
      t.string :username
      t.timestamp :ldap_imported_at
      t.hstore :ldap_attributes

      t.timestamps
    end
    add_index :users, :object_guid, :unique => true
    add_index :users, :username, :unique => true
  end
end
