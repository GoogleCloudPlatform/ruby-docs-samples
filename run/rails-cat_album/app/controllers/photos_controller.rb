class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show edit update destroy ]

  # GET /photos or /photos.json
  def index
    @photos = Photo.all
  end

  # GET /photos/1 or /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  # def edit
  # end

  # POST /photos or /photos.json
  def create
    @photo = Photo.new(photo_params)
    image = params[:photo][:image]
    caption = params[:photo][:caption]


    if @photo.save
      @photo.image.attach(image) if image
      redirect_to photos_path, notice: 'Photo was successfully uploaded.'
    else
      flash.now[:alert] = 'Photo could not be saved.'
      render :new
    end
  end

  # PATCH/PUT /photos/1 or /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: "Photo was successfully updated." }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1 or /photos/1.json
  def destroy
    @photo.image.purge
    @photo.destroy
    redirect_to photos_path, notice: "Photo successfully deleted"
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.require(:photo).permit(:caption)
    end
end
