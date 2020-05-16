class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  # calculating cost of a booking less than a full day
  # or calculate the cost of extra hours on a multi day booking
  def hours_cost(hourly_rate, daily_rate)
    hours = self.end_time - self.start_time
    hours_cost = hours * hourly_rate
    if hours_cost > daily_rate
      return daily_rate
    else
      return hours_cost
  end

  def days_cost(daily_rate)
    days = self.end_date - self.start_date
    return days * daily_rate
  end

  def calculate_cost(booking)
    listing = Listing.find(booking.listing_id)
    if booking.start_date == booking.end_date
      return hours_cost(listing.hourly_rate, listing.daily_rate)
    else
      if booking.start_time >= booking.end_time
        return days_cost(listing.daily_rate)
      else
        extra_hours = booking.end_time - booking.start_time
        return days_cost(listing.daily_rate) + hours_cost(listing.hourly_rate, listing.daily_rate)
      end
    end
  end
end

