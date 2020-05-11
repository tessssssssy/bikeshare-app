class BookingsController < ApplicationController
    def new
        @booking = Booking.new
    end
    def create
        @booking = current_user.bookings.create(booking_params)            
        if @booking.save
            redirect_to root_path
            # this is where you should direct to stripe to make deposit
        end
    end
    private
    def booking_params
      params.require(:booking).permit(:start_time, :end_time, :user_id, :listing_id)
    end
end

