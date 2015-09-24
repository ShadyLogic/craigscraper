class Page < ActiveRecord::Base
	belongs_to :list
	has_many :images
end
