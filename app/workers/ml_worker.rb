class MlWorker
  include Sidekiq::Worker

  def perform(image_id)
    image = Image.find_by id: image_id
    return if !image || image.processed?

    labels = fetch_labels(image)
    unless labels.empty?
      labels.each do |label|
        puts "\nLabel: #{label}\n"
        image.label_list.add(label.name)
      end
      image.processed = true
      image.save
    end
  end

  private

  def fetch_labels(image)
    credentials = Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )
    client = Aws::Rekognition::Client.new credentials: credentials
    if Rails.env.development? && !image.picture_url
      attrs = {
        image: {
          bytes: picture.download
        },
        max_labels: 15
      }
    else
      attrs = {
        image: {
          s3_object: {
            bucket: ENV['S3_BUCKET'],
            name: image.filename
          }
        },
        max_labels: 15
      }
    end
    response = client.detect_labels attrs
    puts "RESPONSE LABELS: #{response.labels}"
    response.labels
  end
end
