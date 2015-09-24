class List < ActiveRecord::Base
	has_many :pages
	has_many :images, through: :pages
end
