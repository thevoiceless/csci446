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

	# Create HTML select dropdown with values 1 through 100
	def generate_rank_values
		list = "<select name=\"rank\">"
		for i in 1..100
			list += "<option value=\"#{i}\">#{i}</option>"
		end
		list += "</select>"
	end

	# Display the results list (table)
	def render_list(request)
		response = Rack::Response.new
		# Write partial HTML
		File.open("list.html", "rb") { |list| response.write(list.read) }
		# Generate "sorted by" text
		response.write(generate_sorted_by(request))
		# Generate the results
		response.write(generate_sorted_table(request))
		# Finish HTML response
		response.write(closing_html)
		response.finish
	end

	# Provide list.css file requested by list.html
	def render_list_css
		response = Rack::Response.new
		File.open("list.css", "rb") { |css| response.write(css.read) }
		response.finish
	end

	# Any invalid path will display the value of env
	def render_404(env)
		[404, {"Content-Type" => "text/plain"}, ["env: #{env.to_s}"]]
	end

	# Sort the albums array and return HTML for the "sorted by" text
	def generate_sorted_by(request)
		# Sort the albums based on the "order" param from query string
		order = request.GET()["order"]
		case order
		when "rank" then @albums.sort_by! { |album| album[@@COL_RANK] }
		when "name" then @albums.sort_by! { |album| album[@@COL_NAME] }
		when "year" then @albums.sort_by! { |album| album[@@COL_YEAR] }
		else @albums.sort_by! { |album| album[@@COL_RANK] }
		end
		# Return the HTML displaying the sort order
		"<p>Sorted by #{order}</p>"
	end

	# Generate HTML for the results table based on the query
	def generate_sorted_table(request)
		# Get the rank to highlight from the query string
		rank_to_highlight = request.GET()["rank"].to_i
		# Generate table HTML
		table_content = "<table>"
		@albums.each do |album|
			if album[@@COL_RANK] == rank_to_highlight
				table_content += "<tr id=\"highlight\"><td>#{album[@@COL_RANK]}</td>"
			else
				table_content += "<tr><td>#{album[@@COL_RANK]}</td>"
			end
			table_content += "<td>#{album[@@COL_NAME]}</td><td>#{album[@@COL_YEAR]}</td></tr>"
		end
		table_content += "</table>"
	end

	# Close body and html tags
	def closing_html
		"</body></html>"
	end
end

Signal.trap('INT') {
	Rack::Handler::WEBrick.shutdown
}

Rack::Handler::WEBrick.run(AlbumOrganizer.new, {:Port => 8080})