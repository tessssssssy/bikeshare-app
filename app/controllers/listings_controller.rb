class ListingsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_listing ,only: [:show, :edit, :update, :destroy] 
    def index
        @listings = Listing.search(params[:search])
    end

    def show
    end

    def new
        @listing = Listing.new
        @location = Location.new
    end

    def create
      p params
      p current_user
      location = Location.create(location_params)
      @listing = current_user.listings.create(listing_params.merge(location_id: location.id))
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
      params.require(:listing).permit(:title, :description, :category, :image, :instant_pickup)
    end
    def location_params
      params.require(:location).permit(:address, :post_code, :city, :country, :listings)
    end
  
    def find_listing
      @listing = Listing.find(params[:id])
    end
end

