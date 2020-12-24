class DropArchivesTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :archives
  end
end
