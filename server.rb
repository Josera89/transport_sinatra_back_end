require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext' # required for .to_json

configure do
  db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
  set :mongo_db, db[:test]
end

get '/collections/?' do
  content_type :json
  settings.mongo_db.database.collection_names.to_json
end

# list all documents in the test collection
get '/documents/?' do
  content_type :json
  settings.mongo_db.find.to_a.to_json
end

# insert a new document from the request parameters,
# then return the full document
post '/new_document/?' do
  content_type :json
  db = settings.mongo_db
  result = db.insert_one params
  db.find(:_id => result.inserted_id).to_a.first.to_json
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def object_id val
    begin
      BSON::ObjectId.from_string(val)
    rescue BSON::ObjectId::Invalid
      nil
    end
  end

  def document_by_id id
    id = object_id(id) if String === id
    if id.nil?
      {}.to_json
    else
      document = settings.mongo_db.find(:_id => id).to_a.first
      (document || {}).to_json
    end
  end
end
