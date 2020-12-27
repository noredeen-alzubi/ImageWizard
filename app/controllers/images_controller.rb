class ImagesController < ApplicationController
  before_action :set_image, only: %i[show destroy edit_privacy]
  before_action :authenticate_user!, only: %i[my_index new bulk_new create bulk_create destroy get_presigned_urls edit_privacy]

  # GET /images
  def index
    puts params
    if params[:search]
      labels = params[:search].split(',').map(&:strip)
      @images = Image.tagged_with(labels, any: true).only_public.by_join_date.page(params[:page] || 1)
      @query = labels.join(', ')
    else
      @images = Image.only_public.by_join_date.page(params[:page] || 1)
    end
  end

  def my_index
    @images = current_user.images
  end

  # GET /images/1
  def show
    if @image.private? && @image.user != current_user
      redirect_to(images_path, notice: 'You are not authorized to view this page.')
    end
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /bulk/new
  def bulk_new
    @image = Image.new
  end

  # GET /presigned_urls
  def get_presigned_urls
    if !params[:count] && !params[:count].is_a?(Integer)
      head :bad_request
    end

    signatures = []
    params[:count].to_i.times do
      data = Image.new_presigned_url
      signatures << data
    end

    render json: signatures, status: :ok
  end

  # POST /images
  def create
    @image = Image.new(image_params.merge(user_id: current_user.id))
    if @image.save
      render json: JSON::parse(@image.to_json).merge(image_url: url_for(@image)), status: :created
    else
      head :unprocessable_entity
    end
  end

  # POST /bulk/single
  def bulk_create
    @image = Image.new(image_params.merge(user_id: current_user.id))
    if @image.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  # PATCH /images/1
  def edit_privacy
    head :forbidden if @image.user != current_user

    @image.private = image_params[:private] if image_params[:private]

    if @image.save
      head :ok
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

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:picture_url, :private)
  end
end
