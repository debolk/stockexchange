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

# REST API
get '/commodities' do
  Commodity.all.to_json only: [:id, :name], methods: :bar_price
end

get '/buy_orders' do
  BuyOrder.order(price: :desc).to_json only: [:id, :phone, :amount, :price], include: :commodity
end

get '/buy_orders/:id' do |id|
	begin
		BuyOrder.find(id).to_json only: [:id, :phone, :amount, :price], include: :commodity
	rescue ActiveRecord::RecordNotFound
		halt 404, "Order not found!"
	end
end

get '/sell_orders' do
  SellOrder.order(price: :desc).to_json only: [:id, :phone, :amount, :price], include: :commodity
end

get '/sell_orders/:id' do |id|
	begin
		SellOrder.find(id).to_json only: [:id, :phone, :amount, :price], include: :commodity
	rescue ActiveRecord::RecordNotFound
		halt 404, "Order not found!"
	end
end

# Interface
get '/interface/bar' do
  haml :'interface/bar'
end
