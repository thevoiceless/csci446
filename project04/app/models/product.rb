class Product < ActiveRecord::Base
	attr_accessible :description, :image_url, :price, :title

	has_many :line_items

	# If the hook method returns false, the row will not be destroyed
	before_destroy :ensure_not_referenced_by_any_line_item

	validates :title, :description, :image_url, presence: true
	validates :title, uniqueness: true
	# Compare to 0.01 instead of zero because entering a price of 0.001 would
	# pass validation but be stored as zero in the database
	validates :price, numericality: { greater_than_or_equal_to: 0.01 }
	validates :image_url, allow_blank: true, format: {
		with:    %r{\.(gif|jpg|png)$}i,
		message: 'must be a URL for GIF, JPG or PNG image.'
	}

	private

	def ensure_not_referenced_by_any_line_item
		if line_items.empty?
			return true
		else
			errors.add(:base, 'Line Items present')
			return false
		end
	end
end
