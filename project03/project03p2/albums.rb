require 'sinatra'
require 'data_mapper'
require_relative 'album'

class AlbumOrganizer < Sinatra::Base

	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/albums.sqlite3.db")
	set :port, 8080

	def stylesheet_link(name)
		"<link rel=\"stylesheet\" type=\"text/css\" href=\"#{name}\">"
	end

	get "/" do
		redirect "/form"
	end

	get "/form" do
		erb :form
	end

	post "/list" do
		@order_by = params['order']
		@rank_to_highlight = params['rank'].to_i
		@stylesheet = stylesheet_link("list.css")
		@albums = Album.all(:order => [ @order_by.to_sym ])
		erb :list
	end
end

AlbumOrganizer.run!