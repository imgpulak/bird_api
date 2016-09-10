require 'minitest'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'httpclient'
require 'multi_json'

load_arr = []
load_arr.each do |lib|
        require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

class TestPostBirds < Minitest::Test
        def setup
		@httpclint = HTTPClient.new
        end

        def test_post_birds_valid_data_only_required_fields
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Snow partridge", "family": "Lerwa lerwa", "continents": ["India"]}'
		bird_info_hash_from_json_data = MultiJson.load(json_data)
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		# check status code
		assert_equal(201, status_code)	
		body = response.body
		bird_info_hash = MultiJson.load(body)
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

        def test_post_birds_valid_data
		base_url = "http://localhost:7777/birds"
		header = {"Content-Type" => "application/json"}
		json_data = '{"name": "Green peafowl", "family": "Pavo muticus", "continents": ["India"]}'
		bird_info_hash_from_json_data = MultiJson.load(json_data)
		response = @httpclint.post(base_url, json_data, header)
		status_code = response.status
		# check status code
		assert_equal(201, status_code)	
		body = response.body
		bird_info_hash = MultiJson.load(body)
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
end
