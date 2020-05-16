class RemoveTimeFromBooking < ActiveRecord::Migration[6.0]
  def change
    remove_column :bookings, :start_time, :time
    remove_column :bookings, :end_time, :time
  end
end
