require 'sinatra'
require 'data_mapper'
require_relative 'Album'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/albums.sqlite3.db")
set :port, 8080

get "/" do
  "Sinatra is working!"
end
