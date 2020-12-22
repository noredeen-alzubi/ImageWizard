class Image < ApplicationRecord
  belongs_to :user
  after_commit :get_ml_data, on: :create
  has_one_attached :picture

  private

  def get_ml_data
    puts '\n====== in here ======\n'
  end
  handle_asynchronously :get_ml_data
end
