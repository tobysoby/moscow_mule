require 'rubygems'
require 'sinatra'
require 'json'
require 'yaml'
require './import_features.rb'
require './import_config.rb'

config = YAML.load_file('./moscow_mule.config')

data = import

set :port, config["port"]

get '/' do
	@data = data
	File.read(File.join('public', 'index.html'))
end

get '/api/features' do
	content_type :json
	data[:features].to_json
end

get '/api/features/:id' do
	content_type :json
	data[:features][params['id'].to_i].to_json
end

get '/api/scenarios' do
	content_type :json
	data[:scenarios].to_json
end

get '/api/tags/global' do
	content_type :json
	data[:tags][:global].to_json
end

get '/api/tags/testplans' do
	content_type :json
	data[:tags][:testplans].to_json
end

get '/api/tags/platforms' do
	content_type :json
	data[:tags][:platforms].to_json
end

get '/api/tags/testers' do
	content_type :json
	data[:tags][:testers].to_json
end

get '/api/data' do
	content_type :json
	data.to_json
end

get '/reload/' do
	import_config
	data = import
	redirect to('/')
end