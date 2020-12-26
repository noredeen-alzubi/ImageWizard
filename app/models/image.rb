class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :picture
  acts_as_ordered_taggable_on :labels
  paginates_per 7

  after_commit :process
  before_destroy :handle_s3_resource
  scope :by_join_date, -> { order('created_at DESC') }
  scope :only_public, -> { where(private: false) }

  def process
    MlWorker.perform_async(id) unless processed? || destroyed?
  end

  def handle_s3_resource
    S3Worker.perform_async(filename) if picture_url
  end

  # Cannot user <%= image_tag %> with this
  def cdn_url
    if picture_url
      "//#{ENV['CDN_HOST']}/#{filename}"
    elsif Rails.env.development? || Rails.env.test?
      Rails.application.routes.url_helpers.rails_blob_url(picture, only_path: true)
    else
      "//#{ENV['CDN_HOST']}/#{picture.url}"
    end
  end

  def filename
    if picture_url
      picture_url.match(/(?<=com\/).*/).to_s
    else
      return nil unless picture.attached?

      picture.filename.to_s
    end
  end
end
