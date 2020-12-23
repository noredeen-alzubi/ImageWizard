class MlWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    puts 'hello from the background'
  end
end
