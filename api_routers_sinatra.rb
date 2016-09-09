require 'sinatra'

load_arr=["./lib/general_methods.rb", "./lib/logger.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

set :public_folder, File.dirname(__FILE__) + './public'
set :general_methods, GeneralMethods.new


# all routes 

get '/help' do
	'TODO'
end

post '/birds' do
	request.body.rewind  # in case someone already read it
	body = request.body.read
	response = settings.general_methods.post_bird(params, body)
	set_response(response)
end

get '/birds' do
	response = settings.general_methods.get_birds(params)
	set_response(response)
end

get '/birds/:id' do 
	response = settings.general_methods.get_bird_by_id(params)
	set_response(response)
end

delete '/birds/:id' do 
	response = settings.general_methods.delete_bird_by_id(params)
	set_response(response)
end

not_found do
	$log.info "API Page not found, params #{params}"
	response = settings.general_methods.get_response_hash(404)
	set_response(response)
end

error do
	status_code = env['sinatra.error'].http_status.to_i
	$log.info "Sorry there was a error - " + env['sinatra.error'].message + " for params #{params}. status code is #{status_code}"
	response = settings.general_methods.get_response_hash(status_code)
	set_response(response)
end

def set_response(response = {})
	status(response[:status])
	content_type(response[:content_type], {charset: 'utf-8'}) if response[:content_type]
	body(response[:body]) if response[:body]
end
