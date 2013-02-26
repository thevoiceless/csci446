class Cart < ActiveRecord::Base
	# attr_accessible :title, :body

	# A cart has many line items
	# The existence of line items is dependent on the existence of the cart
	has_many :line_items, dependent: :destroy
end
