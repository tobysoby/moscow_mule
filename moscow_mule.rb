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
	@data = data
	#puts "Params: " + params['id']
	#puts @data[params['id'].to_i]
	feature = @data["features"][params['id'].to_i]
	content_type :json
	feature.to_json
end