class ListingsController < ApplicationController
    load_and_authorize_resource 
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_listing ,only: [:show, :edit, :update, :destroy]
    before_action :set_user_listing, only: [:edit]
    def index
        @listings = [] 
        if params[:search] && params[:search] != ''
          locations = Location.search_city(params[:search])
          coordinates = Geocoder.search(params[:search]).first.coordinates
        else
          locations = Location.all
        end
        Listing.all.each do |listing|
          locations.each do |location|
            if listing.location_id == location.id
              @listings << listing
            end
          end
        end
        p "******#{@listings}********"
        # show only listings available for these dates
        if params[:start_date] && params[:end_date]
          if params[:start_date] != "" && params[:end_date] != ""
            @listings = @listings.filter { |listing| listing.check_availability(params[:start_date], params[:end_date]) } 
          end  
        end  
        # show only listings with instant pickup available
        if params[:instant_pickup]
          @listings = @listings.filter { |listing| listing.instant_pickup }
        end
        # sort listings by most reviews
        # if listings.sort by most reviewed
        if params[:sort_method] == "0"
          @listings = @listings.sort_by { |listing| listing.average_rating }.reverse
        else
          @listings = @listings.sort_by { |listing| listing.reviews.length }.reverse     
        end
      if params[:type] == "json"
        data = @listings.map do |listing|
          [listing.location.latitude, listing.location.longitude]
        end
        render json: { data: data, center: coordinates }
      end    
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
      location = Location.new(location_params)
      location.latitude = Geocoder.coordinates(location.address, :params => {:region => location.country})[0]
      location.longitude = Geocoder.coordinates(location.address, :params => {:region => location.country})[1]
      location.save
      @listing = current_user.listings.create(listing_params.merge(location_id: location.id))
      if @listing.save
        redirect_to @listing
      else
        render :new
      end
    end

    def edit
      @location = Location.find(@listing.location_id)
    end

    def update 
      @location = Location.find(@listing.location_id)
      new_location = Location.new(location_params)
      new_location.latitude = Geocoder.coordinates(new_location.address, :params => {:region => new_location.country})[0]
      new_location.longitude = Geocoder.coordinates(new_location.address, :params => {:region => new_location.country})[1]
      new_location.save
      @listing.location_id = new_location.id
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
      params.require(:listing).permit(:title, :description, :category, :image, :instant_pickup, :hourly_rate, :daily_rate)
    end
    def location_params
      params.require(:location).permit(:address, :post_code, :city, :country, :listings, :latitude, :longitude)
    end
  
    def find_listing
      @listing = Listing.find(params[:id])
    end

    def set_user_listing
      id = params[:id]
      @listing = current_user.listings.find_by_id(id)
    
      if @listing == nil
        redirect_to listings_path
      end
    end
end

