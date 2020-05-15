class BookingsController < ApplicationController
    before_action :authenticate_user!
    def index
       @bookings = current_user.bookings
    end
    def show
        @booking = Booking.find(params[:id])
    end
    def new
        @listing = Listing.find(params[:listing_id])
        @booking = Booking.new
    end
    def create
        p params
        p current_user
        @booking = Booking.new
        @booking.user_id = current_user.id
        @booking.listing_id = params[:listing_id]
        @booking.start_date = params[:booking][:start_date]
        @booking.end_date = params[:booking][:end_date] 
        # check if current user owns listing and mark confirmed = true
        listing = Listing.find(params[:listing_id])
        if current_user.id == listing.user_id
            @booking.confirmed = true
        end      
        if @booking.save
            redirect_to "/listings/#{@booking.listing_id}/bookings/#{@booking.id}"
        end
    end

    private
    def booking_params
      params.require(:booking).permit(:start_time, :end_time)
    end
end


