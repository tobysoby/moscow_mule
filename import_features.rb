# encoding: utf-8

require 'gherkin/parser'
require 'gherkin/pickles/compiler'

def import
	#remove all images
	FileUtils.rm_rf('./public/assets/images/')
	FileUtils.mkdir('./public/assets/images/')

	#location_features = @config[:location_features]
	@location_features = "../features_test_en"
	data = Hash.new

	features = Array.new

	old_path = Dir.pwd
	Dir.chdir(@location_features)
	feature_files = Dir.glob("*.*")
	Dir.chdir(old_path)

	feature_files.each_with_index do |feature_file, index_feature_file|
		file = File.open(@location_features + "/" + feature_file, "r:UTF-8")
		content = file.read
		parser = Gherkin::Parser.new
		gherkin_document = parser.parse(content)
		#pickles = Gherkin::Pickles::Compiler.new.compile(gherkin_document, "../features/" + feature_file)
		features.push gherkin_document
	end
	data[:features] = features
	data[:scenarios] = read_scenarios(features)
	data[:tags] = read_tags_from_scenarios(data[:scenarios])
	return data
end

def read_tags_from_scenarios (scenarios)
	# get the tags from the scenarios
	tags = Hash.new
	global = Hash.new
	testers = Hash.new
	platforms = Hash.new
	testplans = Hash.new
	scenarios.each do |scenario|
		if scenario[:type] == :Scenario
			if scenario[:tags].size != 0
				scenario[:tags].each do |tag|
					global = putTagIntoHash(tag, scenario, global)
				end
			end
		end
	end
	
	global.keys.each do |tag_name|
		tag = global[tag_name]
		# which tags are for testers
		if isTester(tag[:name])
			testers = putSpecificTagIntoHash(tag, testers, "@tester:")
		end
		# which tags are for platforms
		if isPlatform(tag[:name])
			platforms = putSpecificTagIntoHash(tag, platforms, "@platform:")
		end
		# which tags are for testplans
		if isTestplan(tag[:name])
			testplans = putSpecificTagIntoHash(tag, testplans, "@testplan:")
		end
	end

	tags[:global] = global
	tags[:testers] = testers
	tags[:platforms] = platforms
	tags[:testplans] = testplans
	return tags
end

def read_scenarios (features)
	id = 0
	scenarios = Array.new
	features.each do |feature|
		feature[:feature][:children].each do |scenario|
			scenario[:id] = id
			scenario = hasImages(scenario)
			id += 1
			scenarios.push scenario
		end
	end
	return scenarios
end

def hasImages (scenario)
	images_arr = Array.new
	puts scenario
	if scenario[:type] == :Scenario
		scenario[:tags].each do |tag|
			if tag[:name].index("image:")
				image_name = tag[:name].sub("@image:", "")
				FileUtils.cp @location_features + '/images/' + image_name, './public/assets/images/' + image_name
				images_arr.push './assets/images/' + image_name
			end
		end
	end
	scenario[:images] = images_arr
	return scenario
end

def putTagIntoHash (tag, scenario, hashToPutInto)
	# if the tag already is in the hash
	if hashToPutInto.key?(tag[:name])
		arr = hashToPutInto[tag[:name]][:scenarios]
		arr.push [scenario[:name], scenario[:id]]
		foo = Hash.new
		foo[:name] = tag[:name]
		foo[:scenarios] = arr
		hashToPutInto[tag[:name]] = foo
	# if not
	else
		arr = Array.new
		arr.push [scenario[:name], scenario[:id]]
		foo = Hash.new
		foo[:name] = tag[:name]
		foo[:scenarios] = arr
		hashToPutInto[tag[:name]] = foo
	end
	return hashToPutInto
end

# returns a hash with 
def putSpecificTagIntoHash (tag, hashToPutInto, substring)
	foo = Hash.new
	foo[:name] = tag[:name].sub(substring, "")
	foo[:scenarios] = tag[:scenarios]
	hashToPutInto[tag[:name]] = foo
	return hashToPutInto
end

def isTester (tag)
	if tag.index("tester:")
		return true
	else
		return false
	end
end

def isPlatform (tag)
	if tag.index("platform:")
		return true
	else
		return false
	end
end

def isTestplan (tag)
	if tag.index("testplan:")
		return true
	else
		return false
	end
end