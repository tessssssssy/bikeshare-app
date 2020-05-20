
class ReviewsController < ApplicationController
    def index
        @reviews = Review.all
    end

    # new review form
    def new
        @review = Review.new
    end

    # create a new review
    def create
        @listing = Listing.find(params[:listing_id])
        @review = @listing.reviews.create(review_params.merge(user_id: current_user.id))
        if @review.save
            redirect_to @listing
        end
    end
    # delete a review
    def destroy
        @listing = Listing.find(params[:listing_id])
        @review = @listing.reviews.find(params[:id])
        @review.destroy
        redirect_to @listing
    end

    private
    # permit params for review
    def review_params
      params.require(:review).permit(:body, :rating)
    end
end


