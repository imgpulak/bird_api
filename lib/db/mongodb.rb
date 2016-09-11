require 'mongo'

load_arr = ["../logger.rb"]
load_arr.each do |lib|
	require File.expand_path(File.dirname(__FILE__)+"/"+lib)
end

# This creates Namespace DB
module DB
	class MongoDB
	end
end

# This is MongoDB wrapper class, contains various methods
class DB::MongoDB

	def initialize(database_name, args_hash = {})
		connect_to_database(database_name, args_hash)
	end

	# This connects mongodb databases. TODO we should take MongoDB host and port from config.
	# @param [String] database_name database name to connect
	# @param [Hash] args_hash one optional hash 
	# @retrun [Mongo::Client] mongo cleint per database
	def connect_to_database(database_name, args_hash={})
		$log.info "going to connect to MongoDB at 127.0.0.1:27017"
		@client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => database_name)
	end

	# It inserts one documents into a collection. 
	# @param [String] collection_name collection name to insert docuement
	# @param [Hash] document_hash docuement to insert into the collection
	# @param [Hash] args_hash one optional hash 
	# @retrun [BSON::ObjectId] BSON::ObjectId of the document
	def insert_one_document_into_a_collection(collection_name, document_hash, args_hash={})
		$log.info "inserting document(#{document_hash}) into the collection #{collection_name}"
		collection = @client[collection_name.to_sym]
		result = collection.insert_one(document_hash)
		document_id = result.inserted_id
		$log.info "document_id: #{document_id}"
		return document_id
	end
	
	# It read documents from a collection as per filter. 
	# @param [String] collection_name collection name
	# @param [Hash] filter condition hash to use while selecting documents
	# @param [Hash] args_hash one optional hash. Keys are :limit which limits how many documents to retrun 
	# @retrun [Array] array of BSON::Document as return
	def get_documents_from_a_collection(collection_name, filter, args_hash={})
		$log.info "getting documents from the collection #{collection_name}"
		document_hash_array = []
		collection = @client[collection_name.to_sym]
		if (args_hash[:limit] and args_hash[:limit] >= 1)
			documents = collection.find(filter).limit(args_hash[:limit])
		else
			documents = collection.find(filter)
		end
		return documents
	end
	
	# It deletes only one document from a collection as per filter. 
	# @param [String] collection_name collection name
	# @param [Hash] filter condition hash to use while deleting a document
	# @param [Hash] args_hash one optional hash 
	# @retrun [BSON::Document]
	def delete_a_documents_from_a_collection(collection_name, filter, args_hash={})
		$log.info "deleting a document from the collection #{collection_name}"
		collection = @client[collection_name.to_sym]
		return collection.find_one_and_delete(filter)
	end
end
