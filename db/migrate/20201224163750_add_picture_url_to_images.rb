class AddPictureUrlToImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :picture_url, :string
  end
end
