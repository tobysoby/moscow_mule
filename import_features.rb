def import
	data = Hash.new
	features = Array.new
	#load all Files
	all_feature_files = Dir["../features/*.feature"]
	#create all Features
	all_feature_files.each_with_index do |feature_file, index_feature_files|
		feature = Hash.new
		scenarios = Array.new
		#load the content of the feature_file
		content = File.readlines feature_file
		content.each_with_index do |line, index_feature_lines|
			#if the line starts with Funktionalität
		begin
			if line.include? "Funktionalität"
				#this line is the title of the Funktionalität
				feature["feature_title"] = line.sub!("Funktionalität: ", "")
				#check the following lines
				#loop through 1..100, this should usually be enough for the descrition of a feature
				feature_description = ""
				for i in 1..100
					#if the next line does not start with Szenario or is a Tag
					if (!content[index_feature_lines+i].include? "Szenario") || (!content[index_feature_lines+i].include? "@")
						feature_description = feature_description + content[index_feature_lines+i]
					else
						feature["feature_description"] = feature_description
						break
					end
				end
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
					begin
						#if its not one of the steps
						if (!content[index_feature_lines+i].include? "Angenommen") && (!content[index_feature_lines+i].include? "Wenn") && (!content[index_feature_lines+i].include? "Dann")
							if content[index_feature_lines+i].include? "Szenario"
								break
							else
								scenario_description = scenario_description + content[index_feature_lines+i]
							end
						elsif content[index_feature_lines+i].include? "Angenommen"
							scenario_steps.push content[index_feature_lines+i]
						elsif content[index_feature_lines+i].include? "Wenn"
							scenario_steps.push content[index_feature_lines+i]
						elsif content[index_feature_lines+i].include? "Dann"
							scenario_steps.push content[index_feature_lines+i]
							break
						end
					rescue
						puts "yepp"
						break
					end
				end
				#get the tags
				for i in 1..100
					if content[index_feature_lines-i].include? "@"
						scenario_tags.push content[index_feature_lines-i]
					elsif content[index_feature_lines-i].include? "#"
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
		rescue
			next
		end

			feature["index"] = index_feature_files
			feature["feature_scenarios"] = scenarios
		end
		#write it into the features-Array
		features.push feature
	end
	#get the testers
	if File.exists?("../features/@testers")
		testers = Array.new
		content = File.readlines ("../features/@testers")
		content.each do |tester|
			testers.push tester
		end
		data["testers"] = testers
	end
	data["features"] = features
	puts data["testers"][0]
	return data
end

def prettify(string)
	string.gsub!('"', '')
	string.gsub!('\n', '<br>')

	return string
end