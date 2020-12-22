class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :description

      t.timestamps
    end
  end
end
