class S3Worker
  include Sidekiq::Worker

  def perform(s3_url)
    S3_BUCKET.object(s3_url).delete
  end
end
