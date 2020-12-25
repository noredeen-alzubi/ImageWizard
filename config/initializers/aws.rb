AWS_CREDENTIALS = Aws::Credentials.new(
  ENV['AWS_ACCESS_KEY_ID'],
  ENV['AWS_SECRET_ACCESS_KEY']
)

S3_BUCKET = Aws::S3::Resource.new(
  region: 'us-east-1',
  credentials: AWS_CREDENTIALS
).bucket('image-wiz-production')

Aws.config.update({
  region: 'us-east-1',
  credentials: AWS_CREDENTIALS
})
