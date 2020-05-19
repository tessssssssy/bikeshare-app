class Location < ApplicationRecord
    has_many :listings
    geocoded_by :full_address 
    after_validation :geocode

    def full_address
      [self.address, self.city, self.country].compact.join(', ')
    end

    def self.search_city(search)
        if search
            return Location.where(city: search)
          else
            return Location.all
          end  
    end
    def self.search_country(search)
        if search
            return Loaction.where(country: search)
          else
            return Location.all
        end  
    end
end
