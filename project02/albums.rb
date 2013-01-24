require 'rack'

class AlbumOrganizer
	@@COL_RANK = 0
	@@COL_NAME = 1
	@@COL_YEAR = 2

	def initialize
		@albums = Array.new
		rank = 1
		File.open("top_100_albums.txt", "r").each_line do |line|
			@albums << [rank] + line.chomp.split(", ")
			rank += 1
		end
	end

	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/" then [ 302, {'Location'=> '/form' }, [] ]
		when "/form" then render_form(request)
		when "/list" then render_list(request)
		else render_404(env)
		end
	end

	private

	def render_form(request)
		response = Rack::Response.new
		File.open("form.html", "rb") { |form| response.write(form.read) }
		response.finish
	end

	def render_list(request)
		response = Rack::Response.new
		File.open("list.html", "rb") { |list| response.write(list.read) }
		response.write(generate_sorted_by(request))
		response.write(generate_sorted_table(request))
		response.write(closing_html)
		#puts "body:", response.body
		response.finish
	end

	def render_404(env)
		[404, {"Content-Type" => "text/plain"}, ["env: #{env.to_s}"]]
	end

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

	def generate_sorted_table(request)
		rank_to_highlight = request.GET()["rank"].to_i
		table_content = "<table>"
		@albums.each do |album|
			if album[@@COL_RANK] == rank_to_highlight
				table_content += "<tr id=\"highlight\" style=\"color: green\"><td>#{album[@@COL_RANK]}</td>"
			else
				table_content += "<tr><td>#{album[@@COL_RANK]}</td>"
			end
			table_content += "<td>#{album[@@COL_NAME]}</td><td>#{album[@@COL_YEAR]}</td></tr>"
		end
		table_content += "</table>"
	end

	def closing_html
		"</body></html>"
	end
end

Rack::Handler::WEBrick.run(AlbumOrganizer.new, {:Port => 8080})