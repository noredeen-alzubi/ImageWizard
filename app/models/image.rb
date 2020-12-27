class Image < ApplicationRecord
  belongs_to :user
  acts_as_ordered_taggable_on :labels
  paginates_per 7
  validates :picture_url, presence: true

  after_commit :process
  before_destroy :handle_s3_resource

  scope :by_join_date, -> { order('created_at DESC') }
  scope :only_public, -> { where(private: false) }

  def process
    MlWorker.perform_async(id) unless processed? || destroyed? || !picture_url
  end

  def handle_s3_resource
    S3Worker.perform_async(filename) if picture_url
  end

  def self.new_presigned_url
    presigned_url = S3_BUCKET.presigned_post(
      key: "#{SecureRandom.uuid}_${filename}",
      success_action_status: '201',
      signature_expiration: (Time.now.utc + 15.minutes),
      acl: 'public-read'
    )
    { url: presigned_url.url, url_fields: presigned_url.fields }
  end

  def fetch_labels
    credentials = Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )
    client = Aws::Rekognition::Client.new credentials: credentials
    attrs = {
      image: {
        s3_object: {
          bucket: ENV['S3_BUCKET'],
          name: filename
        }
      },
      max_labels: 15
    }
    response = client.detect_labels attrs
    response.labels
  end

  def cdn_url
    "//#{ENV['CDN_HOST']}/#{filename}"
  end

  def filename
    picture_url.match(/(?<=com\/).*/).to_s
  end
end
