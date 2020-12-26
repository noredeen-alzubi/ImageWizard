class Image < ApplicationRecord
  belongs_to :user
  acts_as_ordered_taggable_on :labels
  paginates_per 7

  after_commit :process
  before_destroy :handle_s3_resource

  validates :picture_url, presence: true
  scope :by_join_date, -> { order('created_at DESC') }
  scope :only_public, -> { where(private: false) }

  def process
    MlWorker.perform_async(id) unless processed? || destroyed? || !picture_url
  end

  def handle_s3_resource
    S3Worker.perform_async(filename) if picture_url
  end

  # Cannot user <%= image_tag %> with this
  def cdn_url
    "//#{ENV['CDN_HOST']}/#{filename}"
  end

  def filename
    picture_url.match(/(?<=com\/).*/).to_s
  end
end
