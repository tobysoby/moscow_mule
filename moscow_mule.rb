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