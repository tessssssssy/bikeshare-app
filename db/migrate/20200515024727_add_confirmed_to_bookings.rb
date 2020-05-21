# frozen_string_literal: true

class AddConfirmedToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :confirmed, :boolean, default: false
  end
end
