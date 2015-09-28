require 'nokogiri'
require 'open-uri'
require 'httparty'

module Scraper

	BASE_URL = "http://sfbay.craigslist.org"

	extend ActiveSupport::Concern

	def archive_posts(links)
		posts = []
		links.each do |link|
			p "*"*100
			p link
			p "*"*100
			post = Nokogiri::HTML(open(link))
			posts << scrape_info(post)
		end
		posts
	end

	def new_links(address, first_link)
		current_doc = Nokogiri::HTML(open(address))
		current_links = create_urls_from_links(gather_links(current_doc))

		new_links = []

		unless current_links.first == first_link
			current_links.each_index do |i|
				if current_links[i] == first_link
					return new_links
				else
					new_links << current_links[i]
				end
			end
		end

		new_links
	end

	def gather_links(address)
		doc = Nokogiri::HTML(open(address))
		links = doc.search('.row > a:first-child').map do |link|
			link.attributes['href'].value
		end
		links.map { |link| BASE_URL + link }	
	end


	def scrape_info(post)
		info = {
			title: scrape_title(post),
			text: scrape_text(post),
			images: scrape_images(post)
		}

		# unless info[:images].empty?
		# 	info[:images].map { |url| upload_image(url)}
		# end

		info
	end

	def scrape_title(post)
		post.css('title').inner_text
	end

	def scrape_text(post)
		post.css('#postingbody').inner_text
	end

	def scrape_images(post)
		parsed_post = post.css('script')[2].inner_text.split("\"")
		parsed_post.select{ |item| item.include?(".jpg") && !item.include?("50x50") }
	end

	def upload_image(url)

	    body = { 'image' => url }
	    headers = { "Authorization" => "Client-ID " + '8756023387f86f7' }

	    response = HTTParty.post('https://api.imgur.com/3/image',
	                        :body => body,
	                        :headers => headers)

	    image_url = response["data"]["link"]

	    return image_url
	end
end