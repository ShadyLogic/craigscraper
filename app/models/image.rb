class Image < ActiveRecord::Base
	belongs_to :page
	belongs_to :list
end
