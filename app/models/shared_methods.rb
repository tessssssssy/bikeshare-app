# frozen_string_literal: true

module SharedMethods
  # method that turns a date into an integer to make it easier to compare two dates
  def date_to_integer(date)
    date.to_s.split('-').join('').to_i
  end
end
