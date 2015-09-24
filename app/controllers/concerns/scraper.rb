require 'nokogiri'
require 'open-uri'
require 'httparty'

module Scraper

	extend ActiveSupport::Concern

	def initialize(address)
		@address = address
		@doc = Nokogiri::HTML(open(@address))
		@links = create_urls_from_links(gather_links(@doc))
	end

	def archive_posts(links)
		posts = []
		links.each do |link|
			post = Nokogiri::HTML(open(link))
			posts << scrape_info(post)
		end
		posts
	end

	def new_links
		current_doc = Nokogiri::HTML(open(@address))
		current_links = create_urls_from_links(gather_links(current_doc))

		new_links = []

		unless current_links.first == @links.first
			current_links.each_index do |i|
				if current_links[i] == @links.first
					return new_links
				else
					new_links << current_links[i]
				end
			end
		end

		new_links
	end

	private

	def gather_links(doc)
		doc.search('.row > a:first-child').map do |link|
			link.attributes['href'].value
		end		
	end

	def create_urls_from_links(links)
		links.map { |link| "http://sfbay.craigslist.org" + link }	
	end

	def scrape_info(post)
		info = {
			title: scrape_title(post),
			text: scrape_text(post),
			images: scrape_images(post)
		}

		unless info[:images].empty?
			info[:images].map { |url| upload_image(url)}
		end

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

response = HTTParty.post('https://api.imgur.com/3/image', :body => { 'image' => 'http://images.craigslist.org/00O0O_aXf7HaEUXbZ_600x450.jpg' }, :headers => { "Authorization" => "Client-ID 8756023387f86f7" }




