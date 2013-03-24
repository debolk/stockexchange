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
ActiveRecord::Base.include_root_in_json = false

# SETTINGS
set :auth_employee, '214E7DD41B7C823DF963'
set :auth_admin,    '110F4B0BDF366C453723'

require './models/buyorder.rb'
require './models/sellorder.rb'
require './models/commodity.rb'

helpers do
	def auth(admin = false)
		if request.query_string.empty?
			halt 401, "Please add the correct token"
		end
		if request.query_string == settings.auth_admin
			return
		end
		if !admin && request.query_string == settings.auth_employee
			return
		end
		halt 403, "Not authorized!"
	end
end

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

delete '/sell_orders/:id' do |id|
	auth
	begin
		SellOrder.find(id).destroy
	rescue ActiveRecord::RecordNotFound
		halt 404, "Order not found!"
	end
end

delete '/buy_orders/:id' do |id|
	auth
	begin
		BuyOrder.find(id).destroy
	rescue ActiveRecord::RecordNotFound
		halt 404, "Order not found!"
	end
end

post '/sell_orders' do
  auth
  req = ActiveSupport::JSON.decode(request.body)

  begin
    commodity = Commodity.where(:name => req["commodity"]).first!
    order = SellOrder.new
    order.amount = req["amount"]
    order.price = req["price"]
    order.seller = req["seller"]
    order.commodity = commodity
    order.save
    redirect '/sell_orders/' + order.id.to_s
  rescue ActiveRecord::RecordNotFound
    halt 451, "Commodity not found"
  end 
end

post '/buy_orders' do
  auth
  req = ActiveSupport::JSON.decode(request.body)

  begin
    commodity = Commodity.where(:name => req["commodity"]).first!
    order = BuyOrder.new
    order.amount = req["amount"]
    order.price = req["price"]
    order.phone = req["phone"]
    order.commodity = commodity
    order.save
    redirect '/buy_orders/' + order.id.to_s
  rescue ActiveRecord::RecordNotFound
    halt 451, "Commodity not found"
  end 
end
  
# Interface
get '/interface/bar' do
  haml :'interface/bar'
end
