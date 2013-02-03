require 'rack'

class AlbumOrganizer
	# Order of the table columns
	@@COL_RANK = 0
	@@COL_NAME = 1
	@@COL_YEAR = 2

	# Read from the albums file when the AlbumOrganizer is created
	def initialize
		# Save the albums in an array
		@albums = Array.new
		# Albums are listed in order in the text file
		rank = 1
		File.open("top_100_albums.txt", "r").each_line do |line|
			@albums << [rank] + line.chomp.split(", ")
			rank += 1
		end
	end

	def call(env)
		request = Rack::Request.new(env)
		case request.path
		# Redirect "/" to "/form"
		when "/" then [ 302, {'Location'=> '/form' }, [] ]
		when "/form" then render_form(request)
		when "/list" then render_list(request)
		# Provde path to CSS file for "/list"
		when "/list.css" then render_list_css
		else render_404(env)
		end
	end

	private

	# Display the form
	def render_form(request)
		response = Rack::Response.new
		response.write(ERB.new(File.read("form.html.erb")).result(binding))
		response.finish
	end

	# Display the results list (table)
	def render_list(request)
		# Sort the albums based on the "order" param from query string
		case request.GET()["order"]
		when "rank" then @albums.sort_by! { |album| album[@@COL_RANK] }
		when "name" then @albums.sort_by! { |album| album[@@COL_NAME] }
		when "year" then @albums.sort_by! { |album| album[@@COL_YEAR] }
		else @albums.sort_by! { |album| album[@@COL_RANK] }
		end
		# Get the rank to highlight from the query string
		rank_to_highlight = request.GET()["rank"].to_i

		response = Rack::Response.new
		response.write(ERB.new(File.read("list.html.erb")).result(binding))
		response.finish
	end

	# Provide list.css file requested by list.html.erb
	def render_list_css
		response = Rack::Response.new
		File.open("list.css", "rb") { |css| response.write(css.read) }
		response.finish
	end

	# Any invalid path will display the value of env
	def render_404(env)
		[404, {"Content-Type" => "text/plain"}, ["env: #{env.to_s}"]]
	end
end

# Handle Control+C
Signal.trap('INT') {
	Rack::Handler::WEBrick.shutdown
}

Rack::Handler::WEBrick.run(AlbumOrganizer.new, {:Port => 8080})