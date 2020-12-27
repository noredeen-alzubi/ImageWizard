class S3Worker
  include Sidekiq::Worker

  def perform(filename)
    S3_BUCKET.object(filename).delete
  end
end
