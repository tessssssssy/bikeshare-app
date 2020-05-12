class Listing < ApplicationRecord
  validates :title, :description, presence: true
  belongs_to :user
  belongs_to :location
  has_many :bookings, dependent: :destroy
  has_one_attached :image
  def self.search(search)
    if search
      @listings = []
      locations = Location.where(city: search)
      locations.each do |location|
        location.listings.each do |listing|
          @listings << listing
        end
      end
      p @listings
    else
      @listings = Listing.all
    end      
  end

  def date_available?(date)
    bookings = Booking.all
    bookings.each do |booking|
        if booking.start_date < date && booking.end_date > date
            return false
        end
    end
    return true
  end

  def time_available?(time)
    bookings = Booking.all
    bookings.each do |booking|
      if booking.start_time <= time && booking.end_time >= time
          return false
      end
    end
  return true
  end

  def partial_availability(date)
    # date must be available
    if !date_available?(date)
      return false
    end
    # but must have some bookings
    bookings.each do |booking|
      if booking.start_date == date || booking.end_date == date
        return true
      end
    end
    return false
  end

end


