# frozen_string_literal: true

class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new
    can %i[index manage show new create], Listing
    can %i[edit update destroy], Listing, user_id: user.id
    can %i[index new create], Booking
    can %i[show destoy], Booking, user_id: user.id
  end
end
