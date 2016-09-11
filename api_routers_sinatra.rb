require 'sinatra'

load_arr=["./lib/general_methods.rb", "./lib/logger.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

set :public_folder, File.dirname(__FILE__) + './public'
set :general_methods, GeneralMethods.new


# below are the all routes i.e. API end-points 


# POST /birds - Add a new bird
#
# Request POST /birds
#   The body is a JSON object based on the JSON schema can be found in post-birds-request.json.
#   If visible is not set, it should default to false.
#   added should default to today's date (in UTC)
# Response 
#   Valid status codes:
#     201 Created if the bird was successfully added
#     400 Bad request if any mandatory fields were missing or if the input JSON was invalid
#   The body is a JSON object based on the JSON schema can be found in post-birds-response.json.
post '/birds' do
	request.body.rewind  # in case someone already read it
	body = request.body.read
	response = settings.general_methods.post_bird(params, body)
	set_response(response)
end

# GET /birds - List all birds
# 
# Request GET /birds
#   Empty body.
# Response
#   Valid status codes:
#     200 OK
#   The body is a JSON array based on the JSON schema can be found in get-birds-response.json. Only visible birds should be returned.
get '/birds' do
	response = settings.general_methods.get_birds(params)
	set_response(response)
end

# GET /birds/{id} - Get details on a specific bird
# 
# Request GET /birds/{id}
#   Empty body.
# Response
#   Valid status codes:
#     200 OK if the bird exists
#     404 Not found if the bird does not exist
#   A 404 Not found is expected when the bird does not exist. Birds with visible set to false should be returned with a 200 OK.
#   The response body for a 200 OK request can be found in get-birds-id-response.json.
get '/birds/:id' do 
	response = settings.general_methods.get_bird_by_id(params)
	set_response(response)
end

# DELETE /birds/{id} - Delete a bird by id
# 
# Request DELETE /birds/{id}
#   Empty body
# Response
#   Valid status codes:
#     200 OK if the bird has been removed
#     404 Not found if the bird didn't exist
#   Empty body expected.
delete '/birds/:id' do 
	response = settings.general_methods.delete_bird_by_id(params)
	set_response(response)
end

# If you hit a page which is not implemented yet.
not_found do
	$log.info "API Page not found, params #{params}"
	response = settings.general_methods.get_response_hash(404)
	set_response(response)
end

# If unhandled exception occurred
error do
	status_code = env['sinatra.error'].http_status.to_i
	$log.info "Sorry there was a error - " + env['sinatra.error'].message + " for params #{params}. status code is #{status_code}"
	response = settings.general_methods.get_response_hash(status_code)
	set_response(response)
end

# To set response 
# @param [Hash] response a hash contains status, content_type and body
def set_response(response = {})
	status(response[:status])
	content_type(response[:content_type], {charset: 'utf-8'}) if response[:content_type]
	body(response[:body]) if response[:body]
end
