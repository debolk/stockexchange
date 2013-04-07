# Basic setup for every process
require 'bundler/setup'
require 'haml'
require 'sinatra'
require "sinatra/activerecord"
require 'acts_as_paranoid'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'exchange.db',
  host:     'localhost',
)
ActiveRecord::Base.include_root_in_json = false

require './models/buyorder.rb'
require './models/sellorder.rb'
require './models/commodity.rb'
