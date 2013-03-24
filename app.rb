require 'bundler/setup'
require 'sinatra'
require "sinatra/activerecord"
require 'haml'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'exchange.db',
  host:     'localhost',
)

require './models/buyorder.rb'
require './models/commodity.rb'



get '/' do
  @buy_orders = BuyOrder.all
  haml :"buy_orders/index" 
end
