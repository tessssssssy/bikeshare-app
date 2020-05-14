
class ReviewsController < ApplicationController
    def index
        @reviews = Review.all
    end
    def new
        @review = Review.new
    end
    def create
        p params
        @listing = Listing.find(params[:listing_id])
        @review = @listing.reviews.create(review_params.merge(user_id: current_user.id))
        if @review.save
            redirect_to @listing
        end
        # redirect_to @listing
    end

    def edit
    end
    def update
    end
    def destroy
        @listing = Listing.find(params[:listing_id])
        @review = @listing.reviews.find(params[:id])
        @review.destroy
        redirect_to @listing
    end
    private
    def review_params
      params.require(:review).permit(:body, :rating )
    end
end


