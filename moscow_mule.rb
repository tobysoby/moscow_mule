require 'rubygems'
require 'sinatra'
require 'json'
require './import_features.rb'
require './import_config.rb'

import_config

data = import_2

get '/' do
	@data = data
	File.read(File.join('public', 'index.html'))
end

get '/features' do
	content_type :json
	data["features"].to_json
end

get '/features/:id' do
	content_type :json
	data["features"][params['id'].to_i].to_json
end

get '/scenarios' do
	content_type :json
	data["scenarios"].to_json
end

get '/tags/global' do
	content_type :json
	data["tags_global"].to_json
end

get '/tags/testplans' do
	content_type :json
	data["tags_testplans"].to_json
end

get '/tags/platforms' do
	content_type :json
	data["tags_platforms"].to_json
end

get '/tags/testers' do
	content_type :json
	data["tags_testers"].to_json
end

get '/data' do
	content_type :json
	data.to_json
end

get '/reload/' do
	import_config
	data = import_2
	redirect to('/')
end