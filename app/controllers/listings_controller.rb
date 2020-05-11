class ListingsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_listing ,only: [:show, :edit, :update, :destroy] 
    def index
        @listings = Listing.all
    end

    def show
    end

    def new
        @listing = Listing.new
    end

    def create
      @listing = current_user.listings.create(listing_params)
      if @listing.save
        redirect_to @listing
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @listing.update(listing_params)
        redirect_to @listing
      else
        render :edit
      end
    end

    def destroy
      @listing.destroy
      redirect_to listings_path
    end

    private
    def listing_params
      params.require(:listing).permit(:title, :description, :type, :image)
    end
  
    def find_listing
      @listing = Listing.find(params[:id])
    end
end

