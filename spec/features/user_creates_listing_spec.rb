# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User creates listing' do
  scenario 'they see the page for the submitted product' do
    product_title = 'Test-O-Matic 3000'
    product_description = 'Unnecessary'
    # Our listing requires a user and a location to be valid
    Location.create(address: '123 Fake St', post_code: '1234', city: 'Melbourne', country: 'Australia')
    User.create(email: 'test@gmail.com', name: 'Test', password: 'password')

    visit root_path
    click_on 'Add Listing'
    fill_in 'listing_title', with: listing_title
    fill_in 'listing_description', with: listing_description
    click_on 'Submit'

    expect(page).to have_content product_name
  end
end
