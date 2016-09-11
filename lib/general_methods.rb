require 'json'
require 'multi_json'
require 'monitor'
require 'json-schema'

load_arr = ["./logger.rb", "./db/mongodb.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

# This class implemets all methods, which validates input and save input to the databases 
class GeneralMethods
	# a monitor is an object or module intended to be used safely by more than one thread.
	include MonitorMixin

	def initialize(args_hash = {})
		@db_name = "BirdAPIDB"
		@collection_name = "birds"
		@mongodb_obj = DB::MongoDB.new(@db_name)
		load_all_json_schemas
	end

	# It lodas all json-schema files, pasre into Hash and save in a instance variable @all_json_schemas
	def load_all_json_schemas
		json_schema_dir = get_json_schema_dir
		@all_json_schemas = {}
		Dir.glob(json_schema_dir+"/*").each do |json_schema_file_name|
			$log.info "json_schema_file_name: #{json_schema_file_name}"
			schema_name = File.basename(json_schema_file_name)
			$log.info "schema_name: #{schema_name}"
			begin
				schema = MultiJson.load(File.open(json_schema_file_name).read)
				@all_json_schemas[schema_name] = schema
			rescue Exception => e
				$log.error "#{e.class}:#{e.message} for json_schema_file_name: #{json_schema_file_name}"
				$log.info e.backtrace
			end
		end
		$log.info "all_json_schemas: #{@all_json_schemas}"
	end
	
	# It determines the path for json-schema directory
	def get_json_schema_dir
		File.expand_path(File.dirname(__FILE__)+"/"+"./json_schema")
	end

	# This make a response hash 
	# @param [Integer] status returned status code 
	# @param [Hash] body_hash returned body hash
	# @return [Hash] return a response_hash. Keys are status, content_type and body.
	def get_response_hash(status, body_hash=nil)
		body = nil
		body = JSON.pretty_generate(body_hash) if body_hash
		response_hash = {
			status: status, 
			content_type: "application/json", 
			body: body
		}
		$log.info "response_hash: #{response_hash}"
		return response_hash
	end

	# This prase bird info input josn and validates as per json-schema.
	# Then add default fields added and visible
	# @pram [String] bird_info_json a json string as input 
	# @return [Hash] validated bird_info_hash
	def parse_and_validate_bird_info_json(bird_info_json)
		$log.info "bird_info_json: #{bird_info_json}" 
		bird_info_hash = nil
		begin
			bird_info_hash = MultiJson.load(bird_info_json)
			JSON::Validator.validate!(@all_json_schemas['post-birds-request.json'], bird_info_hash)
		rescue Exception => e
			$log.error "#{e.class}:#{e.message} for bird_info_json: #{bird_info_json}, bird_info_hash: #{bird_info_hash}"
			$log.info e.backtrace
			return nil
		end
		# added should default to today's date (in UTC)
		bird_info_hash["added"] = Time.now.utc.strftime("%Y-%m-%d") if not bird_info_hash.key?("added")
		# If visible is not set, it should default to false.
		bird_info_hash["visible"] = false if not bird_info_hash.key?("visible")
		return bird_info_hash	
	end

	# This method implemets 'POST /birds' endpoint
	# @param [Hash] params request parameter hash
	# @param [String] body json input string
	# @return [Hash] return a response_hash. Keys are status, content_type and body.
	def post_bird(params={}, body=nil)
		$log.info "params: #{params}"
		$log.info "body: #{body}"
		bird_info_json = body 
		bird_info_hash = parse_and_validate_bird_info_json(bird_info_json)	
		return get_response_hash(400) if not bird_info_hash
		begin
			document_id = @mongodb_obj.insert_one_document_into_a_collection(@collection_name, bird_info_hash)
			raise Exception.new("could not save bird_info_hash") if not (document_id and document_id.is_a?(BSON::ObjectId))
			bird_info_hash["id"] = document_id.to_s
			JSON::Validator.validate!(@all_json_schemas['post-birds-response.json'], bird_info_hash)
			return get_response_hash(201, bird_info_hash) 
		rescue Exception => e
			$log.error "#{e.class} -> #{e.message} for params #{params} and body: #{body}"
			$log.info e.backtrace
			return get_response_hash(500)
		end
	end

	# This method implemets 'GET /birds' endpoint
	# @param [Hash] params request parameter hash
	# @return [Hash] return a response_hash. Keys are status, content_type and body.
	def get_birds(params = {})
		query_hash = {
			"visible" => true
		}
		bird_id_array = []
		begin
			@mongodb_obj.get_documents_from_a_collection(@collection_name, query_hash).each do |bird_document|
					id = bird_document[:_id].to_s
					bird_id_array << id
			end
			JSON::Validator.validate!(@all_json_schemas['get-birds-response.json'], bird_id_array)
			return get_response_hash(200, bird_id_array)
		rescue Exception => e
			$log.error "#{e.class} -> #{e.message} for params #{params}"
			$log.info e.backtrace
			return get_response_hash(500)
		end
	end
	
	# This method implemets 'GET /birds/{id}' endpoint
	# @param [Hash] params request parameter hash. Key is 'id'
	# @return [Hash] return a response_hash. Keys are status, content_type and body.
	def get_bird_by_id(params = {})
		bird_info_hash = {}
		begin
			id = params["id"]
			query_hash = {
				:_id => BSON::ObjectId(id)
			}
			bird_document = @mongodb_obj.get_documents_from_a_collection(@collection_name, query_hash, :limit => 1).first
			return get_response_hash(404) if not bird_document
			bird_document.each do |key, val|
				if key == "_id"
					bird_info_hash["id"] = val.to_s
				else
					bird_info_hash[key] = val
				end
			end
			JSON::Validator.validate!(@all_json_schemas['get-birds-id-response.json'], bird_info_hash)
			return get_response_hash(200, bird_info_hash)
		rescue BSON::ObjectId::Invalid => e
			return get_response_hash(404)
		rescue Exception => e
			$log.error "#{e.class} -> #{e.message} for params #{params}"
			$log.info e.backtrace
			return get_response_hash(500)
		end
	end
	
	# This method implemets 'DELETE /birds/{id}' endpoint
	# @param [Hash] params request parameter hash. Key is 'id'
	# @return [Hash] return a response_hash. Keys are status, content_type and body.
	def delete_bird_by_id(params = {})
		bird_info_hash = {}
		begin
			id = params["id"]
			query_hash = {
				:_id => BSON::ObjectId(id)
			}
			bird_document = @mongodb_obj.delete_a_documents_from_a_collection(@collection_name, query_hash)
			return get_response_hash(404) if not bird_document.is_a?(BSON::Document)
			return get_response_hash(200)
		rescue BSON::ObjectId::Invalid => e
			return get_response_hash(404)
		rescue Exception => e
			$log.error "#{e.class} -> #{e.message} for params #{params}"
			$log.info e.backtrace
			return get_response_hash(500)
		end
	end
end
