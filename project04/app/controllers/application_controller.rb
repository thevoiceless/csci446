class ApplicationController < ActionController::Base
	protect_from_forgery

	private

		# Placing this method in ApplicationController and marking it private
		# makes the method available only to controllers and prevents Rails
		# from making it available as an action on the controller
		def current_cart
			Cart.find(session[:cart_id])
		rescue ActiveRecord::RecordNotFound
			cart = Cart.create
			session[:cart_id] = cart.id
			cart
		end
end
