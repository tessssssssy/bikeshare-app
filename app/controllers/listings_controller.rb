class ListingsController < ApplicationController
    load_and_authorize_resource 
    before_action :authenticate_user!, except: [:index, :show]
    before_action :find_listing ,only: [:show, :edit, :update, :destroy]
    before_action :set_user_listing, only: [:edit]
    def index
        @listings = [] 
        if params[:city] && params[:city] != ''
          # get locations that match the search params
          locations = Location.search_city(params[:city])         
          coordinates = Geocoder.coordinates(params[:city])
        else
          locations = Location.all
        end
        # loop through all listings and check if it's location_id matches any locations
        # then add matching listings into listings array
        Listing.all.each do |listing|
          locations.each do |location|
            if listing.location_id == location.id
              @listings << listing
            end
          end
        end  
        if params[:start_date] && params[:end_date]
          if params[:start_date] != "" && params[:end_date] != ""
            # filter listings based on whether they are available within the dates 
            @listings = @listings.filter { |listing| listing.check_availability(params[:start_date], params[:end_date]) } 
          end  
        end
        # order listing according to the type of sort selected in sort form
        if params[:sort_method] == "0"
          # order by highest average rating
          @listings = @listings.sort_by { |listing| listing.average_rating }.reverse
        else
          # order by most ratings
          @listings = @listings.sort_by { |listing| listing.reviews.length }.reverse     
        end
      # map search bar
      # re-centers map based on search params
      if params[:type] == "json"
        data = @listings.map do |listing|
          [listing.location.latitude, listing.location.longitude]
        end
        render json: { data: data, center: [data[0][0], data[0][1]] }
      end
      # render "/listings?search=#{params[:city]}&start_date=#{params[:start_date]}&end_date=#{params[:end_date]}"    
    end

    def search
      # finds coordinates of location passed into search bar
      location = Geocoder.search(params[:search])[0].data["geometry"]["location"]
      @listings = Listing.all 
      data = @listings.map do |listing|
        [listing.location.latitude, listing.location.longitude]
      end
      render json: {data: data, center: [location["lat"], location["lng"]]}  
    end 

    # gets all the listings belonging to current user
    def manage
      @listings = current_user.listings
    end

    # show page for listing
    def show
      # new review form
      @review = Review.new
    end

    # renders new listing form
    def new
        @listing = Listing.new
        @location = Location.new
    end

    # creates a new listing
    def create
      location = Location.new(location_params)
      location.save
      @listing = current_user.listings.create(listing_params.merge(location_id: location.id))
      if @listing.save
        redirect_to @listing
      else
        render :new
      end
    end
    # renders edit listing form
    def edit
      # gets the location for the listing to be edited so, that attributes relating to lisitng location can be updated
      @location = Location.find(@listing.location_id)
    end

    def update 
      # get the listings location
      @location = Location.find(@listing.location_id)
      # make a new location with updated params
      new_location = Location.new(location_params)
      # if the location is different from the previous one, save the new location and add it to the listing
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

    # delete a listing
    def destroy
      @listing.destroy
      redirect_to listings_path
    end

    private
    # permit params for listing
    def listing_params
      params.require(:listing).permit(:title, :description, :category, :image, :instant_pickup, :hourly_rate, :daily_rate)
    end
    # permit params for location
    def location_params
      params.require(:location).permit(:address, :post_code, :city, :country, :listings, :latitude, :longitude)
    end
  
    def find_listing
      @listing = Listing.find(params[:id])
    end

    # check if current user is the listing owner
    # used for authoriztion to edit, delete listings
    def set_user_listing
      id = params[:id]
      @listing = current_user.listings.find_by_id(id)
    
      if @listing == nil
        redirect_to listings_path
      end
    end
end

