class AddAuthorization < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :access_level, :integer, default: 0, index: true
  end

end
