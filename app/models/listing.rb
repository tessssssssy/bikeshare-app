# frozen_string_literal: true

require 'booking.rb'
require 'shared_methods.rb'

class Listing < ApplicationRecord
  include SharedMethods
  validates :title, :description, :category, :daily_rate, :hourly_rate, presence: true
  belongs_to :user
  belongs_to :location
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one_attached :image

  # def self.search(search)
  #   if search
  #     location = Location.find_by(city: search)
  #     @listings = Listing.includes(:tags).where('location.id' => image_tag.id).all
  #   else
  #     @listings = Listing.all
  #   end
  # end

  # def self.search_category(search)
  #   if search
  #     self.where(category: category)
  #   else
  #     @listings = Listing.all
  #   end
  # end

  # checks if a particular date is available for a listing
  def date_available?(date)
    bookings = Booking.where(listing_id: id)
    bookings.each do |booking|
      if booking.start_date < date && booking.end_date > date && booking.confirmed == true
        return false
      end
    end
    true
  end

  # checks availability for a listing within a range of dates
  def check_availability(start_date, end_date)
    bookings = Booking.where(listing_id: id)
    bookings.each do |booking|
      if date_to_integer(booking.start_date) < date_to_integer(start_date) &&
         date_to_integer(booking.end_date) > date_to_integer(end_date)
        return false
      end
    end
    true
  end

  # checks if a particular time of day is available
  def time_available?(time, date)
    bookings = Booking.where(listing_id: id)
    bookings.each do |booking|
      if booking.start_date == date && booking.end_date == date
        return false if booking.start_time <= time && booking.end_time >= time
      end
      if booking.start_date == date
        return false if booking.start_time <= time
      end
      next unless booking.end_date == date
      return false if booking.end_time >= time
    end
    true
  end

  # returns true if a date has some times available but is not fully available
  def partial_availability(date)
    bookings = Booking.where(listing_id: id)
    return false unless date_available?(date)

    bookings.each do |booking|
      return true if booking.start_date == date || booking.end_date == date
    end
    false
  end

  # finds times available for a particular date
  def get_available_times(date)
    bookings = Booking.where(listing_id: id)
    start_time = 0
    end_time = 24
    bookings.each do |booking|
      if booking.start_date == date
        end_time = booking.start_time if end_time > booking.start_time
      end
      next unless booking.end_date == date

      start_time = booking.end_time if start_time < booking.end_time
    end
    "#{date} : available from #{start_time}:00 to #{end_time}:00"
  end

  # gets the average rating for a listing based on its reviews
  def average_rating
    return 0 if reviews.empty?

    sum = 0
    reviews.each do |review|
      sum += review.rating
    end
    sum.to_f / reviews.length
  end
end
