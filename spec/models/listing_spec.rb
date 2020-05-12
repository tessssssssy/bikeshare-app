require 'rails_helper'

RSpec.describe Listing, type: :model do
  subject { described_class.new(
    title: 'Test Product',
    description: 'Doodad',
    instant_pickup: false,
    user: User.new,
    location: Location.new
    # location_id: Location.new(address: '123 fake st', post_code: '1234', city: 'Melbourne', country: 'Australia').id
  )}

  it 'is vaild with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a description' do
    subject.description = nil
    expect(subject).to_not be_valid
  end
end