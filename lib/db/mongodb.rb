require 'mongo'

load_arr = ["../logger.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

module DB
	class MongoDB
	end
end

class DB::MongoDB

	def initialize(database_name, args_hash = {})
		connect_to_database(database_name, args_hash)
	end
	
	def connect_to_database(database_name, args_hash={})
		# TODO we should take MongoDB host and port from config.
		$log.info "going to connect to MongoDB at 127.0.0.1:27017"
		@client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => database_name)
	end

	def insert_one_document_into_a_collection(collection_name, document_hash, args_hash={})
		$log.info "inserting document(#{document_hash}) into the collection #{collection_name}"
		collection = @client[collection_name.to_sym]
		result = collection.insert_one(document_hash)
		document_id = result.inserted_id
		$log.info "document_id: #{document_id}"
		return document_id
	end
	
	def get_documents_from_a_collection(collection_name, query_hash, args_hash={})
		$log.info "getting documents from the collection #{collection_name}"
		document_hash_array = []
		collection = @client[collection_name.to_sym]
		if (args_hash[:limit] and args_hash[:limit] >= 1)
			documents = collection.find(query_hash).limit(args_hash[:limit])
		else
			documents = collection.find(query_hash)
		end
		return documents
	end
end
