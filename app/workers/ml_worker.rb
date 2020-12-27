class MlWorker
  include Sidekiq::Worker

  def perform(image_id)
    image = Image.find_by id: image_id
    return if !image || image.processed?

    labels = image.fetch_labels
    return if !labels || labels.empty?

    labels.each do |label|
      puts "\nLabel: #{label}\n"
      image.label_list.add(label.name)
    end
    image.processed = true
    image.save
  end
end
