class ListingsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    def index
        @listings = Listing.all
    end
    def show
        @listing = Listing.find(params[:id])
    end
    def new
        @listing = Listing.new
    end
    def create

    end
    def edit
    end
    def update
    end
    def destroy
    end
    private
    def listing_params
      params.require(:listing).permit(:title, :description, :image, :fixed, :archived)
    end
  
    def find_topic
      @topic = Topic.find(params[:id])
    end
  end
end

