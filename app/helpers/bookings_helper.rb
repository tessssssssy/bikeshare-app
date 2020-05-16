module BookingsHelper
    def date_to_integer(date)
        date.to_s.split('-').join('').to_i 
    end
end
