class CreateArchives < ActiveRecord::Migration[6.0]
  def change
    create_table :archives do |t|
      t.boolean :processed, default: false, null: false
      t.timestamps
    end
  end
end
