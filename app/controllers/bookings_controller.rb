
class BookingsController < ApplicationController
    before_action :authenticate_user!
    def index
       @bookings = current_user.bookings
    end
    def show
        @booking = Booking.find(params[:id])
        @listing = Listing.find(@booking.listing_id)
    end

    def new
        @listing = Listing.find(params[:listing_id])
        @booking = Booking.new
    end

    def create
        @booking = Booking.new
        #     user_id: current_user.id,
        #     listing_id: params[:listing_id],
        #     start_date: params[:start_date],
        #     end_date: params[:end_date],
        #     start_time: params[:start_time],
        #     end_time: params[:end_time]
        # )
        @booking.user_id = current_user.id
        @booking.listing_id = params[:listing_id]
        @booking.start_date = params[:booking][:start_date]
        @booking.end_date = params[:booking][:end_date]
        @booking.start_time = params[:booking][:start_time]
        @booking.end_time = params[:booking][:end_time]
        # @booking = Booking.create(booking_params.merge(user_id: current_user.id))
        @listing = Listing.find(params[:listing_id])
        if current_user.id == @listing.user_id
            @booking.confirmed = true
        end
        if @booking.start_date == nil || @booking.end_date == nil
            flash[:notice] = "Please select a start date and an end date"
            redirect_to "/listings/#{@listing.id}/bookings/new"
        elsif  date_to_integer(@booking.start_date) > date_to_integer(@booking.end_date)
            flash[:notice] = "End date cannot be before start date"
            redirect_to "/listings/#{@listing.id}/bookings/new"
        elsif @booking.start_date == @booking.end_date && @booking.start_time >= @booking.end_time
            flash[:notice] = "Finish time must be after start time"
            redirect_to "/listings/#{@listing.id}/bookings/new"
        elsif !@listing.check_availability(@booking.start_date, @booking.end_date)
            flash[:notice] = "Booking Dates Unavailable"
            redirect_to "/listings/#{@listing.id}/bookings/new"
        elsif !@listing.time_available?(@booking.start_time, @booking.start_date) || !@listing.time_available?(@booking.end_time, @booking.end_date)
            flash[:notice] = "Available Times: #{@listing.get_available_times(@booking.start_date)}, #{@listing.get_available_times(@booking.end_date)}"
            # flash[:notice] = @listing.get_available_times(@booking.end_date)
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

    def destroy
        @booking = Booking.find(params[:id])
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
end


