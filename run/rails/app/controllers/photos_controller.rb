class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  def index
    @photos = Photo.all
  end

  def show
  end

  def new
    @photo = Photo.new
  end

  def edit
  end

  def create
    @photo = Photo.new photo_params
    image = params[:photo][:image]
    caption = params[:photo][:caption]

    if @photo.save
      @photo.image.attach image if image
      redirect_to photos_path, notice: "Photo was successfully uploaded."
    else
      flash.now[:alert] = "Photo could not be saved."
      render :new
    end
  end

  def update
    respond_to do |format|
      if @photo.update photo_params
        format.html { redirect_to @photo, notice: "Photo was successfully updated." }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @photo.image.purge
    @photo.destroy
    redirect_to photos_path, notice: "Photo successfully deleted"
  end

  private

  def set_photo
    @photo = Photo.find params[:id]
  end

  def photo_params
    params.require(:photo).permit(:caption)
  end
end
