# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :listings
  validates :address, :city, :post_code, :country, presence: true
  geocoded_by :full_address
  after_validation :geocode
  # creates a full address to lookup latitude and longitude more accurately
  def full_address
    [address, city, country].compact.join(', ')
  end

  # gets locations in a particular city
  def self.search_city(search)
    if search
      Location.where(city: search)
    else
      Location.all
      end
  end

  # gets locations in a particular country
  def self.search_country(search)
    if search
      Loaction.where(country: search)
    else
      Location.all
    end
  end
end
