require 'rack'
require 'sqlite3'

class AlbumOrganizer
	# Load the database when the AlbumOrganizer is created
	def initialize
		@db = SQLite3::Database.open("albums.sqlite3.db")
		@db.results_as_hash = true
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