class RemoveActsAsTaggableOnP2 < ActiveRecord::Migration[6.0]
  def change
    drop_table :tags
  end
end
