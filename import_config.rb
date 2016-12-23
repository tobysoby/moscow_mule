def import_config
	config_file_lines = File.readlines "./moscow_mule.config"
	config_file_lines.each do |config_line|
		if config_line.index("location_features")
			@location_features = config_line.sub("location_features=", "")
			puts @location_features
		end
		if config_line.index("language")
			@language = config_line.sub("language=", "")
		end
		if config_line.index("port")
			@port = config_line.sub("port=", "")
			change_port_in_angular(@port)
		end
	end
end

def change_port_in_angular (new_port)
	file_name = "./public/assets/js/app.js"
	text = File.read(file_name)
	new_contents = text.gsub(/localhost:\d{4}/, "localhost:" + new_port)

	# To write changes to the file, use:
	File.open(file_name, "w") {|file| file.puts new_contents }
end