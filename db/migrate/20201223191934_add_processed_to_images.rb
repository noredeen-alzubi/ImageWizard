class AddProcessedToImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :processed, :boolean, default: false, null: false
    remove_column :images, :description
  end
end
