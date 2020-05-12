class Location < ApplicationRecord
    has_many :listings
    def self.search_city(search)
        if search
            self.where(city: search)
          else
            @locations = Location.all
          end  
    end
    def self.search_country(search)
        if search
            self.where(country: search)
          else
            @locations = Location.all
        end  
    end
end
