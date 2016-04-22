#what should the model look like?
# an array of scenario-hashes: scenario = {"id" => id, feature_id => "feature_id", "name" => name, "description" => description, "steps" => [steps], "tags", [tags]}
# an array of feature-hashes: feature = {"id" => id, "name" => name, "description" => description, "scenarios" => [scenario_ids], "feature_file" => feature_file}
# an array of tag-hashes: 

class Scenario
	attr_accessor :id, :feature_id, :name, :description, :steps, :tags

	def initialize(options)
		@id = options[:id]
		@feature_id = options[:feature_id]
		@name = options[:name]
		@description = options[:description]
		@steps = options[:steps]
		@tags = options[:tags]
	end

	def self.all
    	ObjectSpace.each_object(self).to_a
  	end

  	def self.count
    	all.count
  	end
end

def import_2
	#define the return hash
	data = Hash.new

	#define arrays
	features = Array.new
	scenarios = Array.new

	#make a run for all features
	feature_files = Dir[@location_features]
	feature_files.each_with_index do |feature_file, index_feature_file|
		feature = Hash.new
		#load and process feature_file
		feature = load_and_process_feature_file(feature_file)
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
		scenarios_per_feature, scenario_id = feature_file_get_scenarios(feature_file, scenario_id)
		#incorporate the array of scenarios into the overall array of scenarios
		scenarios.push(*scenarios_per_feature)
		#get all scenario_ids and put em into the feature_hash
		feature["scenarios"] = get_scenario_ids(scenarios_per_feature)
	end

	#get all Tags
	scenarios.each do |scenario|


	puts scenarios

	data["features"] = features
	data["scenarios"] = scenarios
	return data
end

def load_and_process_feature_file(feature_file)
	feature = Hash.new
	content = File.readlines feature_file
	content.each_with_index do |line, index_feature_line|
		#if the line starts with Funktionalität
		feature["feature_file"] = File.expand_path(feature_file)
		if line[0..13] == "Funktionalität"
			#this line is the title of the Funktionalität
			feature["name"] = line.sub("Funktionalität: ", "")
			#check the following lines
			#loop through 1..100, this should usually be enough for the description of a feature
			feature_description = ""
			for i in 1..100
				next_line = content[index_feature_line+i]
				#if the next line does not start with Szenario or is a Tag
				if (!next_line.include? "Szenario") && (!next_line.include? "@")
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

def feature_file_get_scenarios(feature_file, scenario_id)
	scenarios = Array.new
	content = File.readlines feature_file
	content.each_with_index do |line, index_feature_line|
		if line.include? "Szenario"
			#there is a Szenario
			scenario = Hash.new
			#set the scenario-id
			scenario["id"] = scenario_id
			scenario_steps = Array.new
			scenario_tags = Array.new
			#this line is the title of the Szenario
			scenario["title"] = line.sub!("Szenario: ", "")
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

def import
	data = Hash.new
	features = Array.new
	#arrays for all tags
	tags_global = Hash.new
	tags_testplans_global = Hash.new
	tags_platforms_global = Hash.new
	tags_testers_global = Hash.new
	#load all Files
	all_feature_files = Dir[@location_features]
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
				feature["feature_title"] = line.sub("Funktionalität: ", "")
				#check the following lines
				#loop through 1..100, this should usually be enough for the description of a feature
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
				#loop through 1..100, this should usually be enough for the description of a scenario and the steps
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
							tags_testplans_gobal= put_into_global_tag_hash(tags_testplans_global, last_line, index_feature_files, scenario["id"].to_s, scenario_title)
						elsif last_line[1..2] == "p_"
							tags_platforms_global = put_into_global_tag_hash(tags_platforms_global, last_line, index_feature_files, scenario["id"].to_s, scenario_title)
						elsif last_line[1..2] == "t_"
							tags_testers_global = put_into_global_tag_hash(tags_testers_global, last_line, index_feature_files, scenario["id"].to_s, scenario_title)
						else
							tags_global = put_into_global_tag_hash(tags_global, last_line, index_feature_files, scenario["id"].to_s, scenario_title)
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

#this reads a file line by line and puts all the lines into an array and puts it into a hash
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

def put_into_global_tag_hash(tag_hash, last_line, index_feature_files, index_scenario, scenario_title)
	#check if the tag has already been added to the tag-hash
	if tag_hash[last_line] != nil
		tag = Hash.new
		tag = tag_hash[last_line]

		#if it has been added, get the array of scenario_ids
		scenario_ids = Array.new
		scenario_ids = tag["scenario_ids"]
		#add the current feature_id and scenario_id
		scenario_ids.push index_feature_files.to_s + "-" + index_scenario
		#update scenario_ids
		tag["scenario_ids"] = scenario_ids


		scenario_titles = Array.new
		scenario_titles = tag["scenario_titles"]
		#write it into the hash
		scenario_titles.push scenario_title
		tag["scenario_titles"] = scenario_titles

		tag_hash[last_line] = tag
	else
		#if it has not been added, make it new
		tag = Hash.new
		#give our tag an id
		tag["id"] = tag_hash.length + 1

		scenario_ids = Array.new
		scenario_ids.push index_feature_files.to_s + "-" + index_scenario
		tag["scenario_ids"] = scenario_ids

		scenario_titles = Array.new
		scenario_titles.push scenario_title
		tag["scenario_titles"] = scenario_titles

		tag_hash[last_line] = tag
	end
	return tag_hash
end