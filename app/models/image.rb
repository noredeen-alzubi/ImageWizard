class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :picture
  acts_as_ordered_taggable_on :labels

  after_commit :process

  def process
    MlWorker.perform_async(id)
  end
end
