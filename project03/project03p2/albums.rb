require 'sinatra'
require 'data_mapper'
require_relative 'Album'

class AlbumOrganizer < Sinatra::Base

	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/albums.sqlite3.db")
	set :port, 8080

	get "/" do
		redirect "/form"
	end

	get "/form" do
		"foo"
	end
end

# Handle Control+C
Signal.trap('INT') {
	Rack::Handler::WEBrick.shutdown
}

Rack::Handler::WEBrick.run(AlbumOrganizer.new, {:Port => 8080})