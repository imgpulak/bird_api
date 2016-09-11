require 'minitest'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'httpclient'
require 'multi_json'

load_arr = []
load_arr.each do |lib|
        require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

# Test cases for 'POST /birds' endpoint
class TestPostBirds < Minitest::Test
        def setup
		@httpclint = HTTPClient.new
        end

        def test_post_birds_valid_json_data_only_required_fields
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Snow partridge", "family": "Lerwa lerwa", "continents": ["India"]}'
		bird_info_hash_from_json_data = MultiJson.load(json_data)
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		body = response.body
		bird_info_hash = MultiJson.load(body)
		
		# check status code
		assert_equal(201, status_code)	
		id = bird_info_hash.delete("id")
		# check bird id 
		assert_equal(true, (id and not id.empty?))
		visible = bird_info_hash.delete("visible")
		# check visible 
		assert_equal(false, visible)
		added = bird_info_hash.delete("added")
		# check added 
		assert_equal(Time.now.utc.strftime("%Y-%m-%d"), added)
		# check bird info hash  
		assert_equal(bird_info_hash_from_json_data, bird_info_hash)
	end

        def test_post_birds_valid_json_data_with_set_visible
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Green peafowl", "family": "Pavo muticus", "continents": ["India"], "visible": true}'
		bird_info_hash_from_json_data = MultiJson.load(json_data)
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		body = response.body
		bird_info_hash = MultiJson.load(body)
		
		# check status code
		assert_equal(201, status_code)	
		id = bird_info_hash.delete("id")
		# check bird id 
		assert_equal(true, (id and not id.empty?))
		added = bird_info_hash.delete("added")
		# check added 
		assert_equal(Time.now.utc.strftime("%Y-%m-%d"), added)
		# check bird info hash  
		assert_equal(bird_info_hash_from_json_data, bird_info_hash)
        end
        
	def test_post_birds_valid_json_data_with_set_added
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Satyr tragopan", "family": "Tragopan satyra", "continents": ["India"], "visible": false, "added": "2016-09-09"}'
		bird_info_hash_from_json_data = MultiJson.load(json_data)
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		body = response.body
		bird_info_hash = MultiJson.load(body)
		
		# check status code
		assert_equal(201, status_code)	
		id = bird_info_hash.delete("id")
		# check bird id 
		assert_equal(true, (id and not id.empty?))
		# check bird info hash  
		assert_equal(bird_info_hash_from_json_data, bird_info_hash)
        end
	
	def test_post_birds_invalid_json_data
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Satyr tragopan", "family": "Tragopan satyra"'
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		# check status code
		assert_equal(400, status_code)	
        end
	
	def test_post_birds_valid_json_data_but_missing_required
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"family": "Lerwa lerwa", "continents": ["India"]}'
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		# check status code
		assert_equal(400, status_code)	
        end
	
	def test_post_birds_valid_json_data_but_schema_mismatch
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Snow partridge", "family": 1, "continents": ["India", "India"]}'
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		# check status code
		assert_equal(400, status_code)	
        end
	
end
