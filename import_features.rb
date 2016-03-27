def import
	data = Hash.new
	features = Array.new
	#an array for all tags
	tags_global = Array.new
	#load all Files
	all_feature_files = Dir["../features/*.feature"]
	#get all Features
	all_feature_files.each_with_index do |feature_file, index_feature_files|
		feature = Hash.new
		scenarios = Array.new
		#load the content of the feature_file
		content = File.readlines feature_file
		content.each_with_index do |line, index_feature_lines|
			#if the line starts with Funktionalität
		#begin
			if line.include? "Funktionalität"
				#this line is the title of the Funktionalität
				feature["feature_title"] = line.sub!("Funktionalität: ", "")
				#check the following lines
				#loop through 1..100, this should usually be enough for the descrition of a feature
				feature_description = ""
				for i in 1..100
					next_line = content[index_feature_lines+i]
					#if the next line does not start with Szenario or is a Tag
					if (!next_line.include? "Szenario") && (!next_line.include? "@")
						feature_description = feature_description + next_line
					else
						break
					end
				end
				feature["feature_description"] = feature_description
			end
			if line.include? "Szenario"
				#there is a Szenario
				scenario = Hash.new
				scenario_steps = Array.new
				scenario_tags = Array.new
				#this line is the title of the Szenario
				scenario_title = line.sub!("Szenario: ", "")
				#check the following line
				#loop through 1..100, this should usually be enough for the descrition of a scenario and the steps
				scenario_description = ""
				#get the description and the steps
				for i in 1..100
					next_line = content[index_feature_lines+i]
					begin
						#if its not one of the steps
						if next_line[0] == "#"
							scenario_description = scenario_description + "<br>" + next_line
						elsif (next_line.include? "Angenommen") || (next_line.include? "Wenn") || (next_line.include? "Dann") 
							scenario_steps.push next_line
						else
							break
						end
					rescue
						puts "yepp1"
						break
					end
				end
				#get the tags
				for i in 1..100
					last_line = content[index_feature_lines-i]
					if last_line[0] == "@"
						#puts last_line
						scenario_tags.push last_line
						#puts scenario_tags
						#check if the tag has been recognized before
						unless tags_global.include?(last_line)
							tags_global << last_line
						end
					elsif last_line[0] == "#"
						next
					else
						break
					end
				end
				scenario["title"] = scenario_title
				scenario["description"] = scenario_description
				scenario["steps"] = scenario_steps
				puts scenario_tags
				scenario["tags"] = scenario_tags
				#push it all into the scenarios-Array
				scenarios.push scenario
			end
		#rescue
		#	puts "yepp2"
		#	next
		#end

			feature["index"] = index_feature_files
			feature["feature_scenarios"] = scenarios
		end
		#write it into the features-Array
		features.push feature
	end
	#get the testers
	data = get_from_file_linebyline("@testers", data, "testers")
	#get the platforms
	data = get_from_file_linebyline("@platforms", data, "platforms")
	#write the features into data
	data["features"] = features
	#write tags_global into data
	data["tags_global"] = tags_global
	return data
end

def get_from_file_linebyline(file, hash, hash_key)
	#does the file exist?
	if File.exists?("../features/" + file)
		things = Array.new
		#read the file line by line
		content = File.readlines ("../features/" + file)
		content.each do |thing|
			#push all things into an array
			things.push thing
		end
		#write the array into the hash
		hash[hash_key] = things
		#return the hash
		return hash
	end
end