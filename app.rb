require 'bundler/setup'
require 'sinatra'
require "sinatra/activerecord"
require 'acts_as_paranoid'
require 'haml'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'exchange.db',
  host:     'localhost',
)

require './models/buyorder.rb'
require './models/sellorder.rb'
require './models/commodity.rb'

get '/commodities' do
  Commodity.all.to_json only: [:id, :name], methods: :bar_price
end

get '/buy_orders' do
  BuyOrder.order(price: :desc).to_json only: [:id, :phone, :amount, :price], include: :commodity
end