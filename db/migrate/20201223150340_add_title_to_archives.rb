class AddTitleToArchives < ActiveRecord::Migration[6.0]
  def change
    add_column :archives, :title, :string, null: false
  end
end
