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
	end
end