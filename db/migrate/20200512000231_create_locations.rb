# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :address
      t.string :post_code
      t.string :suburb
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end
end
