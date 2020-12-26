class RemoveActsAsTaggableOn < ActiveRecord::Migration[6.0]
  def change
    # drop_table :tags
    drop_table :taggings 
  end
end
