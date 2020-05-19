class ListingsController < ApplicationController
    load_and_authorize_resource 
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_listing ,only: [:show, :edit, :update, :destroy]
    before_action :set_user_listing, only: [:edit]
    def index
        @listings = [] 
        if params[:city] && params[:city] != ''
          locations = Location.search_city(params[:city])         
          coordinates = Geocoder.coordinates(params[:city])
        else
          locations = Location.all
        end
        p locations
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
        if params[:sort_method] == "0"
          @listings = @listings.sort_by { |listing| listing.average_rating }.reverse
        else
          @listings = @listings.sort_by { |listing| listing.reviews.length }.reverse     
        end
      if params[:type] == "json"
        data = @listings.map do |listing|
          [listing.location.latitude, listing.location.longitude]
        end
        render json: { data: data, center: [data[0][0], data[0][1]] }
      end    
    end

    def search
      location = Geocoder.search(params[:search])[0].data["geometry"]["location"]
      @listings = Listing.all 
      data = @listings.map do |listing|
        [listing.location.latitude, listing.location.longitude]
      end
      render json: {data: data, center: [location["lat"], location["lng"]]}  
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
      # location.latitude = Geocoder.coordinates(location.address, :params => {:region => location.country})[0]
      # location.longitude = Geocoder.coordinates(location.address, :params => {:region => location.country})[1]
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
      if @location.full_address != new_location.full_address
        new_location.save
        @listing.location_id = new_location.id
      end           
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

