class AddPrivateToImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :private, :boolean, default: false, null: false
  end
end
