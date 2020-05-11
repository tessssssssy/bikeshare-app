class BookingsController < ApplicationController
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
        if @booking.save
            redirect_to listings_path
        end
    end

    private
    def booking_params
      params.require(:booking).permit(:start_time, :end_time)
    end
end


