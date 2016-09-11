require 'minitest'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'httpclient'
require 'multi_json'

load_arr = []
load_arr.each do |lib|
        require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

# This is a test case for 'DELETE /birds/{id}' endpoint
class TestDeleteBirdsByID < Minitest::Test
        def setup
		@httpclint = HTTPClient.new
        end

        def test_get_birds_by_id_visible_set_to_false
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Snow partridge", "family": "Lerwa lerwa", "continents": ["India"]}'
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		# check status code
		assert_equal(201, status_code)	
		
		response = @httpclint.get(base_url)
		status_code = response.status
		# check status code
		assert_equal(200, status_code)	
		body = response.body
		bird_id_array = MultiJson.load(body)
		bird_id = bird_id_array[0]
		assert_equal(true, (bird_id and not bird_id.empty?))
		
		url = base_url + "/" + bird_id
		response = @httpclint.get(url)
		status_code = response.status
		# check status code
		assert_equal(200, status_code)	
		
		response = @httpclint.delete(url)
		status_code = response.status
		# check status code
		assert_equal(200, status_code)	
		
		response = @httpclint.get(url)
		status_code = response.status
		# check status code
		assert_equal(404, status_code)	
	end
        
        def test_get_birds_by_id_invalid_id
		url = "http://localhost:7777/birds/100001"
		response = @httpclint.delete(url)
		status_code = response.status
		# check status code
		assert_equal(404, status_code)	
	end

end
