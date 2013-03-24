require 'bundler/setup'
require 'sinatra'
require "sinatra/activerecord"

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'exchange.db',
  host:     'localhost',
)

require './models/buyorder.rb'
require './models/commodity.rb'



get '/' do
  'Hello World!'  
end
