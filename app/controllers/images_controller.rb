class ImagesController < ApplicationController
  before_action :set_image, only: %i[show destroy]
  before_action :authenticate_user!, only: %i[my_index new bulk_new create bulk_create destroy get_presigned_urls]

  # GET /images
  def index
    puts params
    if params[:search]
      labels = params[:search].split(',').map(&:strip)
      @images = Image.tagged_with(labels, any: true).by_join_date.page(params[:page] || 1)
      @query = labels.join(', ')
    else
      @images = Image.by_join_date.page(params[:page] || 1)
    end
  end

  def my_index
    @images = current_user.images
  end

  # GET /images/:uuid
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  def bulk_new
    @image = Image.new
  end

  def get_presigned_urls
    if !params[:count] && !params[:count].is_a?(Integer)
      head :bad_request
    end

    signatures = []
    params[:count].to_i.times do
      presigned_url = S3_BUCKET.presigned_post(
        key: "#{SecureRandom.uuid}_${filename}",
        success_action_status: '201',
        signature_expiration: (Time.now.utc + 15.minutes),
        acl: 'public-read'
      )
      data = { url: presigned_url.url, url_fields: presigned_url.fields }
      signatures << data
    end
    puts "\n\nSUCCESS: #{signatures}\n\n"
    render json: signatures, status: :ok
  end

  # POST /images
  def create
    @image = Image.new(image_params.merge(user_id: current_user.id))

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_create
    @image = Image.new(image_params.merge(user_id: current_user.id))
    if @image.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to me_images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def image_params
    params.require(:image).permit(:picture, :picture_url)
  end
end
