# frozen_string_literal: true

class ListingsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, except: %i[index show]
  before_action :find_listing, only: %i[show edit update destroy]
  before_action :set_user_listing, only: [:edit]

  # displays listings based on search parameters
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
        @listings << listing if listing.location_id == location.id
      end
    end
    if params[:start_date] && params[:end_date]
      if params[:start_date] != '' && params[:end_date] != ''
        # filter listings based on whether they are available within the dates
        @listings = @listings.filter { |listing| listing.check_availability(params[:start_date], params[:end_date]) }
      end
    end
    # order listing according to the type of sort selected in sort form
    @listings = if params[:sort_method] == '0'
                  # order by highest average rating
                  @listings.sort_by(&:average_rating).reverse
                else
                  # order by most ratings
                  @listings.sort_by { |listing| listing.reviews.length }.reverse
                end
    # map search bar
    # re-centers map based on search params
    if params[:type] == 'json'
      data = @listings.map do |listing|
        [listing.location.latitude, listing.location.longitude]
      end
      render json: { data: data, center: [data[0][0], data[0][1]] }
    end
  end

  def search
    # finds coordinates of location passed into search bar
    location = Geocoder.search(params[:search])[0].data['geometry']['location']
    @listings = Listing.all
    data = @listings.map do |listing|
      [listing.location.latitude, listing.location.longitude]
    end
    render json: { data: data, center: [location['lat'], location['lng']] }
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
    # make a new location based on location params
    new_location = Location.new(location_params)
    # check to make sure no location already exists with same full address before saving  
    # if the location already exists, set new location to the first match (there should be only one match)
    if matching_locations(new_location).length > 0
      new_location = matching_locations(new_location).first
    else
    # if no matching location exists, save the new location 
      new_location.save
    end
    # create a new listing referenced to the current user, using listing params + new_location
    @listing = current_user.listings.create(listing_params.merge(location_id: new_location.id))
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

    # check if any locations already match the new one 
    # if the location already exists, set new location to the first match (there should be only one match)
    if matching_locations(new_location).length > 0
      new_location = matching_locations(new_location).first
    else
    # if no matching location exists, save the new location 
      new_location.save
    end

    # if the location is different from the previous one, set the listings location to the new one
    if @location.full_address != new_location.full_address
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

  # returns matching locations based on a locations full address
  # used in create/update to check if a new location needs to be created for a listing
  def matching_locations(new_location)
    Location.all.select { |location| location.full_address == new_location.full_address }
  end

  def find_listing
    @listing = Listing.find(params[:id])
  end

  # check if current user is the listing owner
  # used for authoriztion to edit, delete listings
  def set_user_listing
    id = params[:id]
    @listing = current_user.listings.find_by_id(id)
    if @listing.nil?
      redirect_to listings_path
    end
  end
end


