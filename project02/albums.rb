require 'rack'

class AlbumOrganizer
	def call(env)
		[200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
	end
end

Rack::Handler::WEBrick.run(AlbumOrganizer.new, :Port => 8080)