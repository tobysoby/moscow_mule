#what should the model look like?
# an array of scenario-hashes: scenario = {"id" => id, feature_id => "feature_id", "title" => title, "description" => description, "steps" => [steps], "tags" => [tags]}
# an array of feature-hashes: feature = {"id" => id, "title" => title, "description" => description, "scenarios" => [scenario_ids], "feature_file" => feature_file}
# an array of tag-hashes: tags_global = {"id" => id, "title" => title, "scenarios" => [scenario_ids]}

def import_2
	# set the language
	keywords_locale = set_language(@language)
	puts keywords_locale

	#define the return hash
	data = Hash.new

	#define arrays
	features = Array.new
	scenarios = Array.new
	tags_global = Array.new
	tags_testers = Array.new
	tags_testplans = Array.new
	tags_platforms = Array.new

	#make a run for all features

	# a hack!!!
	old_path = Dir.pwd
	Dir.chdir("../features")
	feature_files = Dir.glob("*.*")
	Dir.chdir(old_path)
	puts Dir.pwd
	#puts feature_files
	feature_files.each_with_index do |feature_file, index_feature_file|
		feature = Hash.new
		#load and process feature_file
		feature = load_and_process_feature_file("../features/"+ feature_file, keywords_locale)
		feature["id"] = index_feature_file
		features.push feature
	end

	#set the scenario_id
	scenario_id = 0
	#make a run for all scenarios
	features.each do |feature|
		scenarios_per_feature = Array.new
		feature_id = feature["id"]
		feature_file = feature["feature_file"]
		#load and process the feature_file, get back an array of scenarios and the new scenario_id
		scenarios_per_feature, scenario_id = feature_file_get_scenarios(feature_file, scenario_id, feature_id, keywords_locale)
		#incorporate/append the array of scenarios into the overall array of scenarios
		scenarios.push(*scenarios_per_feature)
		#get all scenario_ids and put em into the feature_hash
		feature["scenarios"] = get_scenario_ids(scenarios_per_feature)
	end

	#get all Tags
	scenarios.each do |scenario|
		tags_global, tags_testers, tags_testplans, tags_platforms = get_tags_from_scenarios_sort(scenario, tags_global, tags_testers, tags_testplans, tags_platforms)
	end

	data["tags_global"] = tags_global
	data["tags_testers"] = tags_testers 
	data["tags_testplans"] = tags_testplans
	data["tags_platforms"] = tags_platforms

	data["features"] = features
	data["scenarios"] = scenarios
	return data
end

def load_and_process_feature_file(feature_file, keywords_locale)
	feature = Hash.new
	content = File.readlines feature_file
	content.each_with_index do |line, index_feature_line|
		#if the line starts with Funktionalität
		feature["feature_file"] = File.expand_path(feature_file)
		if line[0..keywords_locale["feature"].length-1] == keywords_locale["feature"]
			#this line is the title of the Funktionalität
			feature["title"] = line.sub(keywords_locale["feature"] + ": ", "")
			#check the following lines
			#loop through 1..100, this should usually be enough for the description of a feature
			feature_description = ""
			for i in 1..100
				next_line = content[index_feature_line+i]
				#if the next line does not start with Szenario or is a Tag
				if (!next_line.include? keywords_locale["scenario"]) && (!next_line.include? "@")
					feature_description = feature_description + next_line
				else
					break
				end
			end
			feature["description"] = feature_description
		end
	end
	return feature
end

def feature_file_get_scenarios(feature_file, scenario_id, feature_id, keywords_locale)
	scenarios = Array.new
	content = File.readlines feature_file
	content.each_with_index do |line, index_feature_line|
		if line.include?(keywords_locale["scenario"] + ":") || line.include?(keywords_locale["scenario_outline"] + ":")
			#there is a Szenario
			scenario = Hash.new
			#set the scenario-id
			scenario["id"] = scenario_id
			#set the feature-id
			scenario["feature_id"] = feature_id
			scenario_steps = Array.new
			scenario_tags = Array.new
			#this line is the title of the Szenario of Scenario Outline
			if line.include? keywords_locale["scenario"] + ":"
				scenario["title"] = line.sub!(keywords_locale["scenario"] + ": ", "")
			elsif line.include? keywords_locale["scenario_outline"] + ":"
				scenario["title"] = line.sub!(keywords_locale["scenario_outline"] + ": ", "")
			end
					
			#check the following line
			#loop through 1..100, this should usually be enough for the description of a scenario and the steps
			scenario_description = ""
			#get the description and the steps
			for i in 1..100
				next_line = content[index_feature_line+i]
				#if this line exists
				if next_line != nil
					#if its not one of the steps
					if next_line[0] == "#"
						scenario_description = scenario_description + "<br>" + next_line
					elsif (next_line.include? keywords_locale["given"]) || (next_line.include? keywords_locale["when"]) || (next_line.include? keywords_locale["then"]) 
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
				last_line = content[index_feature_line-i]
				if last_line[0] == "@"
					#save the tag
					scenario_tags.push last_line
				elsif last_line[0] == "#"
					next
				else
					break
				end
			end
			scenario["description"] = scenario_description
			scenario["steps"] = scenario_steps
			scenario["tags"] = scenario_tags
			#push it all into the scenarios-Array
			scenarios.push scenario
			#increment scenario_id
			scenario_id += 1
		end
	end
	return scenarios, scenario_id
end

def get_scenario_ids(scenarios_per_feature)
	scenario_ids = Array.new
	scenarios_per_feature.each do |scenario|
		scenario_ids.push scenario["id"]
	end
	return scenario_ids
end

def get_tags_from_scenarios_sort(scenario, tags_global, tags_testers, tags_testplans, tags_platforms)
	#get tags from scenario
	tags_from_scenario = scenario["tags"]
	#sort into arrays
	tags_from_scenario.each do |tag_from_scenario|
		#check whats the prefix of the tag
		if tag_from_scenario[1..3] == "tp_"
			check_tag_array(tag_from_scenario, scenario["id"], tags_testplans)
		elsif tag_from_scenario[1..2] == "p_"
			check_tag_array(tag_from_scenario, scenario["id"], tags_platforms)
		elsif tag_from_scenario[1..2] == "t_"
			check_tag_array(tag_from_scenario, scenario["id"], tags_testers)
		else
			check_tag_array(tag_from_scenario, scenario["id"], tags_global)
		end
	end
	return tags_global, tags_testers, tags_testplans, tags_platforms
end

def check_tag_array(tag_from_scenario, scenario_id, tags_array)
	#build an array of all tags
	all_tags = Array.new
	tags_array.each_with_index do |tag, index|
		all_tags.push tag["title"]
	end
	#is our current tag in this array?
	if all_tags.include? tag_from_scenario
		#then alter this entry
		#get the position
		pos_tag_hash = all_tags.index(tag_from_scenario)
		#get the hash
		tag_hash = tags_array[pos_tag_hash]
		tag_hash["scenarios"] = tag_hash["scenarios"].push scenario_id
	else
		#if no -> add new
		tag_hash = Hash.new
		tag_hash["id"] = tags_array.size
		tag_hash["title"] = tag_from_scenario
		tag_hash["scenarios"] = Array.new.push scenario_id
		tags_array.push tag_hash
	end
end

def set_language(language)
	keywords_locale = Hash.new

	if language == "english"
		keywords_locale["feature"] = "Feature"
		keywords_locale["scenario"] = "Scenario"
		keywords_locale["scenario_outline"] = "Scenario Outline"
		keywords_locale["given"] = "Given"
		keywords_locale["when"] = "When"
		keywords_locale["then"] = "Then"
		keywords_locale["and"] = "And"
	end

	return keywords_locale
end