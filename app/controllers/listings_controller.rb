class ListingsController < ApplicationController
	def index
		@listings = Listing.all
		@listings = @listings.listing_type_filter(params[:listing_type_id]) if params[:listing_type_id].present?
		@listings = @listings.type_filter(params[:property_type]) if params[:property_type].present?
		@listings = @listings.beds(params[:beds]) if params[:beds].present?
		@listings = @listings.neighborhood_filter(params[:neighborhood]) if params[:neighborhood].present?
		@listings = @listings.min_price(params[:price_from]) if params[:price_from].present?
		@listings = @listings.max_price(params[:price_to]) if params[:price_to].present?

		@listings = @listings.min_full_baths(params[:full_baths_from]) if params[:full_baths_from].present?
		@listings = @listings.max_full_baths(params[:full_baths_to]) if params[:full_baths_to].present?

		@listings = @listings.min_half_baths(params[:half_baths_from]) if params[:half_baths_from].present?
		@listings = @listings.max_half_baths(params[:half_baths_to]) if params[:half_baths_to].present?
		
		@listings = @listings.paginate(page: params[:page])

		if params[:display].present?
			@display = params[:display]
		else
			@display = 'thumb_list'
		end
	end

	def show
		@listing = Listing.find(params[:id])
		#@photo_urls = @listing.property_photos.all
	end

	def edit
		@listing = Listing.find(params[:id])		
	end

	def update
		@listing = Listing.find(params[:id])		
		if params[:Neighborhood].present?
			neighborhood = Neighborhood.find_by_name(params[:Neighborhood])
			if neighborhood.nil?
				neighborhood = Neighborhood.create(name: params[:Neighborhood])	
			end
			if neighborhood.id != params[:listing][:neighborhood_id]
				params[:listing][:neighborhood_id] = neighborhood.id
			end
		end

		# if params[:main_photo].present?
		#   preloaded = Cloudinary::PreloadedFile.new(params[:main_photo])         
		#   raise "Invalid upload signature" if !preloaded.valid?
		#   @listing.main_photo = preloaded.identifier
		# end
		
		if @listing.update_attributes(listing_params)
			flash[:success] = "Listing updated"
			AgentMailer.listing_changed(@listing, User.all).deliver
			redirect_to @listing
		else
			render 'edit'
		end
	end

	def new
		@listing = current_user.listings.build
		if params[:listing_type_id].present?
			@listing.listing_type_id = params[:listing_type_id]
		end
	end

	def create
		if params[:Neighborhood].present?
			neighborhood = Neighborhood.find_by_name(params[:Neighborhood])
			if neighborhood.nil?
				neighborhood = Neighborhood.create(name: params[:Neighborhood])	
			end
			if neighborhood.id != params[:listing][:neighborhood_id]
				params[:listing][:neighborhood_id] = neighborhood.id
			end
		end

		@listing = current_user.listings.build(listing_params)
		
	    if @listing.save	      
	      flash[:success] = 'Listing created.'
	      redirect_to @listing
	    else
	      render 'new'
	    end
	end

private

    def listing_params
      params.require(:listing).permit(:street_address, :listing_type_id, :main_photo, :price, :status_id, :bed_id, 
      	:full_baths_no, :half_baths_no, :neighborhood_names, :property_type_id,
      	property_photos_attributes: [:id, :photo_url, :_destroy])
    end
end