def import
	data = Hash.new
	features = Array.new
	#arrays for all tags
	tags_global = Hash.new
	tags_testplans_global = Hash.new
	tags_platforms_global = Hash.new
	tags_testers_global = Hash.new
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
			if line[0..13] == "Funktionalität"
				#this line is the title of the Funktionalität
				puts line
				puts line.sub!("Funktionalität: ", "")
				feature["feature_title"] = line.sub("Funktionalität: ", "")
				puts feature["feature_title"]
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
				#get the scenario-id
				scenario["id"] = scenarios.size.to_i + 1
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
					#if this line exists
					if next_line != nil
						#if its not one of the steps
						if next_line[0] == "#"
							scenario_description = scenario_description + "<br>" + next_line
						elsif (next_line.include? "Angenommen") || (next_line.include? "Wenn") || (next_line.include? "Dann") 
							scenario_steps.push next_line
						else
							break
						end
					else
						break
					end
				end
				#get the tags
				for i in 1..100
					last_line = content[index_feature_lines-i]
					if last_line[0] == "@"
						#save the tag
						scenario_tags.push last_line
						#check if the tag is from a testplan and has been recognized before
						if last_line[1..3] == "tp_"
							tags_testplans_gobal= put_into_global_tag_hash(tags_testplans_global, last_line, index_feature_files, scenario["id"].to_s)
						elsif last_line[1..2] == "p_"
							tags_platforms_global = put_into_global_tag_hash(tags_platforms_global, last_line, index_feature_files, scenario["id"].to_s)
						elsif last_line[1..2] == "t_"
							tags_testers_global = put_into_global_tag_hash(tags_testers_global, last_line, index_feature_files, scenario["id"].to_s)
						else
							tags_global = put_into_global_tag_hash(tags_global, last_line, index_feature_files, scenario["id"].to_s)
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
				scenario["tags"] = scenario_tags
				#push it all into the scenarios-Array
				scenarios.push scenario
			end

			feature["index"] = index_feature_files
			feature["feature_scenarios"] = scenarios
		end
		#write it into the features-Array
		features.push feature
	end
	#get the testers
	#data = get_from_file_linebyline("@testers", data, "testers")
	#get the platforms
	#data = get_from_file_linebyline("@platforms", data, "platforms")
	#write the features into data
	data["features"] = features
	#write tags_global into data
	data["tags_global"] = tags_global
	data["tags_testplans_global"] = tags_testplans_global
	data["tags_platforms_global"] = tags_platforms_global
	data["tags_testers_global"] = tags_testers_global
	return data
end

#this read a file line by line and puts all the lines into an array and puts it into a hash
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

def put_into_global_tag_hash(tag_hash, last_line, index_feature_files, index_scenario)
	#check if the tag has already been added to the tag-hash
	if tag_hash[last_line] != nil
		tag = Hash.new
		#if it has been added, get the array of scenario_ids
		scenario_ids = Array.new
		tag = tag_hash[last_line]
		scenario_ids = tag["scenario_ids"]
		#add the current feature_id and scenario_id
		scenario_ids.push index_feature_files.to_s + "-" + index_scenario
		#write it into the hash
		tag["scenario_ids"] = scenario_ids
		tag_hash[last_line] = tag
	else
		#if it has not been added, make it new
		tag = Hash.new
		scenario_ids = Array.new
		scenario_ids.push index_feature_files.to_s + "-" + index_scenario
		tag["scenario_ids"] = scenario_ids
		#give our tag an id
		tag["id"] = tag_hash.length + 1
		tag_hash[last_line] = tag
	end
	return tag_hash
end