require 'rubygems'
require 'sinatra'
require 'json'
require './import_features.rb'
require './import_config.rb'

import_config

data = import

get '/' do
	@data = data
	erb :index
end

get '/features/:id' do
	#get data
	@data = data
	#look-up the right feature from its id
	feature = @data["features"][params['id'].to_i]
	content_type :json
	feature.to_json
end

get '/tags/tags' do
	@data = data
	tags = @data["tags_global"]
	content_type :json
	tags.to_json
end

get '/data' do
	@data = data
	content_type :json
	data.to_json
end

get '/tags/tags/:id' do
	resp = Hash.new
	tags = data["tags_global"]
	tags.each do |key, value|
		if value["id"] == params["id"].to_i
			resp["tag"] = key
			resp["scenario_ids"] = value["scenario_ids"]
			resp["scenario_titles"] = value["scenario_titles"]
		end
	end
	content_type :json
	resp.to_json
end

get '/tags/testplans' do
	@data = data
	tags = @data["tags_testplans_global"]
	content_type :json
	tags.to_json
end

get '/tags/testplans/:id' do
	resp = Hash.new
	tags = data["tags_testplans_global"]
	tags.each do |key, value|
		if value["id"] == params["id"].to_i
			resp["tag"] = key
			resp["scenario_ids"] = value["scenario_ids"]
			resp["scenario_titles"] = value["scenario_titles"]
		end
	end
	content_type :json
	resp.to_json
end

get '/tags/platforms' do
	@data = data
	tags = @data["tags_platforms_global"]
	content_type :json
	tags.to_json
end

get '/tags/platforms/:id' do
	resp = Hash.new
	tags = data["tags_platforms_global"]
	tags.each do |key, value|
		if value["id"] == params["id"].to_i
			resp["tag"] = key
			resp["scenario_ids"] = value["scenario_ids"]
			resp["scenario_titles"] = value["scenario_titles"]
		end
	end
	content_type :json
	resp.to_json
end

get '/tags/testers' do
	@data = data
	tags = @data["tags_testers_global"]
	content_type :json
	tags.to_json
end

get '/tags/testers/:id' do
	resp = Hash.new
	tags = data["tags_testers_global"]
	tags.each do |key, value|
		if value["id"] == params["id"].to_i
			resp["tag"] = key
			resp["scenario_ids"] = value["scenario_ids"]
			resp["scenario_titles"] = value["scenario_titles"]
		end
	end
	content_type :json
	resp.to_json
end

get '/reload/' do
	data = import
	redirect to('/')
end