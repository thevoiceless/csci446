require 'rack'

class AlbumOrganizer
	def initialize
		albums = Array.new
		rank = 1
		File.open("top_100_albums.txt", "r").each_line do |line|
			albums << ["#{rank}"] + line.chomp.split(", ")
			rank += 1
		end
	end

	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/form" then render_form(request)
		when "/list" then render_list(request)
		else render_404(env)
		end
	end

	def render_form(request)
		response = Rack::Response.new
		File.open("form.html", "rb") { |form| response.write(form.read) }
		response.finish
	end

	def render_list(request)
		response = Rack::Response.new(request.path)
		response.finish
	end

	def render_404(env)
		[404, {"Content-Type" => "text/plain"}, ["env: #{env.to_s}"]]
	end
end

Rack::Handler::WEBrick.run(AlbumOrganizer.new, {:Port => 8080})