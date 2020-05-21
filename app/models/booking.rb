# frozen_string_literal: true

require 'listing.rb'
require 'shared_methods.rb'

class Booking < ApplicationRecord
  include SharedMethods
  belongs_to :user
  belongs_to :listing

  # calculates the cost for extra hours - or for bookings that are less than a day
  def hours_cost
    listing = Listing.find(listing_id)
    hours = end_time - start_time
    hours_price = hours * listing.hourly_rate
    if hours_price > listing.daily_rate
      listing.daily_rate
    else
      hours_price
    end
  end

  # calculates the cost of each day based on listing daily rate
  def days_cost
    listing = Listing.find(listing_id)
    daily_rate = listing.daily_rate
    days = date_to_integer(end_date) - date_to_integer(start_date)
    days * daily_rate
  end

  # gets the total cost of booking by adding the cost of the total days and any extra hours
  def calculate_cost
    listing = Listing.find(listing_id)
    if start_date == end_date
      hours_cost
    else
      if start_time >= end_time
        days_cost
      else
        extra_hours = end_time - start_time
        days_cost + hours_cost
      end
    end
  end
end
