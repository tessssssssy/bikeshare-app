require 'booking.rb'
require 'shared_methods.rb'

class Listing < ApplicationRecord
  include SharedMethods
  validates :title, :description, presence: true
  belongs_to :user
  belongs_to :location
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one_attached :image
  def self.search(search)
    if search
      location = Location.find_by(city: search)
      @listings = Listing.includes(:tags).where('location.id' => image_tag.id).all
      # self.where(location_id: location)
    else
      @listings = Listing.all
    end      
  end
  
  def self.search_category(search)
    if search
      self.where(category: category)
    else
      @listings = Listing.all
    end      
  end

  def date_available?(date)
    bookings = Booking.where(listing_id: self.id)
    bookings.each do |booking|
        if booking.start_date < date && booking.end_date > date && booking.confirmed == true
            return false
        end
    end
    return true
  end

  def check_availability(start_date, end_date)
    bookings = Booking.where(listing_id: self.id)
    bookings.each do |booking|
        if date_to_integer(booking.start_date) < date_to_integer(start_date) && 
           date_to_integer(booking.end_date) > date_to_integer(end_date)
            return false
        end
    end
    return true
  end

  def time_available?(time, date)
    bookings = Booking.where(listing_id: self.id)
    bookings.each do |booking|
      if booking.start_date == date && booking.end_date == date
        if booking.start_time <= time && booking.end_time >= time
          return false
        end
      end
      if booking.start_date == date
        if booking.start_time <= time 
          return false
        end
      end
      if booking.end_date == date
        if booking.end_time >= time
          return false
        end
      end
    end
  return true
  end

  def partial_availability(date)
    bookings = Booking.where(listing_id: self.id)
    if !date_available?(date)
      return false
    end
    bookings.each do |booking|
      if booking.start_date == date || booking.end_date == date
        return true
      end
    end
    return false
  end

  def get_available_times(date)
    bookings = Booking.where(listing_id: self.id)
    start_time = 0
    end_time = 24
    bookings.each do |booking|
      if booking.start_date == date
        if end_time > booking.start_time
          end_time = booking.start_time
        end
      end
      if booking.end_date == date
        if start_time < booking.end_time
          start_time = booking.end_time
        end
      end
    end
    return "#{date} : available from #{start_time} to #{end_time}"
  end
  def average_rating
    sum = 0
    self.reviews.each do |review|
      sum += review.rating
    end
    return sum.to_f / self.reviews.length
  end
end


