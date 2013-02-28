class LineItem < ActiveRecord::Base
	attr_accessible :cart_id, :product_id, :quantity

	# No line item can exist without the corresponding cart and product rows
	belongs_to :product
	belongs_to :cart
end
