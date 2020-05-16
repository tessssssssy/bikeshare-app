class AddTimesToBooking < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :start_time, :integer
    add_column :bookings, :end_time, :integer
  end
end
