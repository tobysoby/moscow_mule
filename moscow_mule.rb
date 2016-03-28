require 'rubygems'
require 'sinatra'
require 'json'
require './import_features.rb'

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

get '/tags/' do
	@data = data
	tags = @data["tags_global"]
	content_type :json
	tags.to_json
end

get '/tags/testplans' do
	@data = data
	tags = @data["tags_testplans_global"]
	content_type :json
	tags.to_json
end

get '/tag/testplans/:name' do
	tags_links = data["tags_testplans_global"][params['name']]
	content_type :json
	tags_links.to_json
end

get '/tags/platforms' do
	@data = data
	tags = @data["tags_platforms_global"]
	content_type :json
	tags.to_json
end

get '/tags/testers' do
	@data = data
	tags = @data["tags_testers_global"]
	content_type :json
	tags.to_json
end