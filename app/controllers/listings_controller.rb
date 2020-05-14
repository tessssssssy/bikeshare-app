class ListingsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_listing ,only: [:show, :edit, :update, :destroy] 
    def index
        @listings = []
        locations = Location.search_city(params[:search]) 
        Listing.all.each do |listing|
          locations.each do |location|
            if listing.location_id == location.id
              @listings << listing
            end
          end
        end
        if params[:start_date] && params[:end_date]
          if params[:start_date] != "" && params[:end_date] != ""
            @listings = @listings.filter { |listing| listing.check_availability(params[:start_date], params[:end_date]) } 
          end  
        end  
        if params[:instant_pickup]
          @listings = @listings.filter { |listing| listing.instant_pickup }
        end
      if params[:type] == "json"
        data = @listings.map do |listing|
          [listing.location.latitude, listing.location.longitude]
        end 
        render json: {data: data}
      end
      p @listings
    end

    def manage
      @listings = current_user.listings
    end
    def show
      @review = Review.new
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
      params.require(:listing).permit(:title, :description, :category, :image, :instant_pickup, )
    end
    def location_params
      params.require(:location).permit(:address, :post_code, :city, :country, :listings, :latitude, :longitude)
    end
  
    def find_listing
      @listing = Listing.find(params[:id])
    end
end

