class Archive < ApplicationRecord
  belongs_to :user
  has_one_attached :zip_file

  validates :title, presence: true
end
