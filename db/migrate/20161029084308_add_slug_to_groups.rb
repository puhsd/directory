class AddSlugToGroups < ActiveRecord::Migration[5.2]
  def up
    add_column :groups, :slug, :string
    add_index :groups, :slug, unique: true
    Group.find_each(&:save)
  end
  def down
    remove_column :groups, :slug, :string
  end
end
