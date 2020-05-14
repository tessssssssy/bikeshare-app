class Listing < ApplicationRecord
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
    bookings = self.bookings.all
    bookings.each do |booking|
        if booking.start_date < date && booking.end_date > date
            return false
        end
    end
    return true
  end

  def check_availability(start_date, end_date)
    bookings = self.bookings.all
    p Date.parse(start_date)
    bookings.each do |booking|
        if booking.start_date < Date.parse(start_date) && 
           booking.end_date > Date.parse(end_date)
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


