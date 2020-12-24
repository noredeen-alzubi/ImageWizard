class MlWorker
  include Sidekiq::Worker

  def perform(image_id)
    image = Image.find_by id: image_id
    return if !image or image.processed?

    labels = fetch_labels(image.picture)
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

  def fetch_labels(picture)
    credentials = Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )
    client = Aws::Rekognition::Client.new credentials: credentials
    if Rails.env.development?
      attrs = {
        image: {
          bytes: picture.download
        }
      }
    else
      attrs = {
        image: {
          s3_object: {
            bucket: ENV['S3-BUCKET'],
            name: picture.filename.to_s
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
