# frozen_string_literal: true

class AddInstantPickupToListings < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :instant_pickup, :boolean
  end
end
