# frozen_string_literal: true

class AddEndDateToBooking < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :end_date, :date
  end
end
