# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_booking, only: %i[show edit update destroy]

  # retrieves all the current users upcoming bookings
  def index
    @bookings = current_user.bookings.where(date_to_integer(:end_date) >= date_to_integer(Date.today)).sort_by(&:start_date)
  end

  # confrimation page for the booking, directs user to stripe payment
  def show
    @listing = Listing.find(@booking.listing_id)
  end

  # renders form for new booking
  def new
    @listing = Listing.find(params[:listing_id])
    @booking = Booking.new
  end

  # create a booking
  def create
    @booking = Booking.new
    # for some reason itwould not let me create a booking using booking_params and also add the listing_id, so I had to manually add each attribute
    @booking.user_id = current_user.id
    @booking.listing_id = params[:listing_id]
    @booking.start_date = params[:booking][:start_date]
    @booking.end_date = params[:booking][:end_date]
    @booking.start_time = params[:booking][:start_time]
    @booking.end_time = params[:booking][:end_time]

    # automatically sets confirmed to true if a listing is booked by its own user
    # if it's a different user they have to pay a deposit before it is confirmed
    @listing = Listing.find(params[:listing_id])
    @booking.confirmed = true if current_user.id == @listing.user_id
    # lots of conditionals for invaild date inputs  or unavailable dates and times with flash messages
    if @booking.start_date.nil? || @booking.end_date.nil?
      flash[:notice] = 'Please select a start date and an end date'
      redirect_to "/listings/#{@listing.id}/bookings/new"
    elsif date_to_integer(@booking.start_date) > date_to_integer(@booking.end_date)
      flash[:notice] = 'End date cannot be before start date'
      redirect_to "/listings/#{@listing.id}/bookings/new"
    elsif @booking.start_date == @booking.end_date && @booking.start_time >= @booking.end_time
      flash[:notice] = 'Finish time must be after start time'
      redirect_to "/listings/#{@listing.id}/bookings/new"
    elsif !@listing.check_availability(@booking.start_date, @booking.end_date)
      flash[:notice] = 'Booking Dates Unavailable'
      redirect_to "/listings/#{@listing.id}/bookings/new"
    elsif !@listing.time_available?(@booking.start_time, @booking.start_date) || !@listing.time_available?(@booking.end_time, @booking.end_date)
      flash[:notice] = "Available Times: #{@listing.get_available_times(@booking.start_date)}, #{@listing.get_available_times(@booking.end_date)}"
      redirect_to "/listings/#{@listing.id}/bookings/new"
    else
      if @booking.save
        if current_user.id == @listing.user_id
          redirect_to listings_path
        else
          redirect_to "/listings/#{@booking.listing_id}/bookings/#{@booking.id}"
          end
      else
        render :new
      end
    end
  end

  # delete a booking
  def destroy
    @booking.destroy
    redirect_to bookings_path
  end

  private

  def booking_params
    params.require(:booking).permit(:start_time, :end_time, :start_date, :end_date, :listing_id)
  end

  def date_to_integer(date)
    date.to_s.split('-').join('').to_i
  end

  def find_booking
    @booking = Booking.find(params[:id])
  end
end
