require 'listing.rb'
require 'shared_methods.rb'

class Booking < ApplicationRecord
  include SharedMethods
  belongs_to :user
  belongs_to :listing
  
  # calculates the cost for extra hours - or for bookings that are less than a day
  def hours_cost
    listing = Listing.find(self.listing_id)
    hours = self.end_time - self.start_time
    hours_price = hours * listing.hourly_rate
    if hours_price > listing.daily_rate
      return listing.daily_rate
    else
      return hours_price
    end
  end

  # calculates the cost of each day based on listing daily rate
  def days_cost
    listing = Listing.find(self.listing_id)
    daily_rate = listing.daily_rate
    days = date_to_integer(self.end_date) - date_to_integer(self.start_date)
    return days * daily_rate
  end

  # gets the total cost of booking by adding the cost of the total days and any extra hours
  def calculate_cost
    listing = Listing.find(self.listing_id)
    if self.start_date == self.end_date
      return self.hours_cost
    else
      if self.start_time >= self.end_time
        return self.days_cost
      else
        extra_hours = self.end_time - self.start_time
        return self.days_cost + self.hours_cost
      end
    end
  end
end

