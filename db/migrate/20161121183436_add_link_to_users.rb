class AddLinkToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :link, :string
    User.all.each { |user| user.set_default_url }
  end
  def down
    remove_column :users, :link, :string
  end
end
