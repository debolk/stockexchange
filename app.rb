# Basic setup for every process
require 'bundler/setup'
require 'haml'
require 'sinatra'
require "sinatra/activerecord"
require 'acts_as_paranoid'
require './sms.rb'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'exchange.db',
  host:     'localhost',
)
ActiveRecord::Base.include_root_in_json = false

require './models/buyorder.rb'
require './models/sellorder.rb'
require './models/commodity.rb'


# SETTINGS
set :auth_employee, '214E7DD41B7C823DF963'
set :auth_admin,    '110F4B0BDF366C453723'


helpers do
	def auth(admin = false)
		if request.query_string.empty?
			halt 401, "Please add the correct token"
		end
    if not auth?(admin)
  		halt 403, "Not authorized!"
    end
	end

  def auth?(admin = false)
		if request.query_string == settings.auth_admin
			return true
		end
		if !admin && request.query_string == settings.auth_employee
			return true
		end
    return false
  end

  def match!
    BuyOrder.order(price: :desc).each do |buy_order|
      sell_orders = SellOrder.order(price: :desc).where('price <= ?', buy_order.price).limit(buy_order.amount)
      if sell_orders.count == buy_order.amount
        buy_order.update_attribute :state, :matched
        sell_orders.update_all state: :matched
      end
    end
  end
end

# REST API
get '/commodities' do
  if auth? admin: true
    Commodity.all.to_json only: [:id, :name, :supply_rate, :supply_price], methods: :bar_price
  else
    Commodity.all.to_json only: [:id, :name], methods: :bar_price
  end
end

get '/commodities/:name' do |name|
  begin
    commodity = Commodity.where(:name => name).first!
    if auth? admin: true
      Commodity.all.to_json only: [:id, :name, :supply_rate, :supply_price], methods: :bar_price
    else
      Commodity.all.to_json only: [:id, :name], methods: :bar_price
    end
  rescue ActiveRecord::RecordNotFound
    halt 404, "Commodity not found!"
  end
end

get '/commodities/:name/propose' do |name|
  commodity = Commodity.where(:name => name).first!
  total = 0
  left = params[:amount].to_i
  BuyOrder.order(price: :desc).each do |buy_order|
    break if buy_order.amount > left
    total += buy_order.total_value
    left -= buy_order.amount
  end
  total += left*commodity.buyback_price
  halt 200, total.to_s
end

get '/buy_orders' do
  BuyOrder.order(price: :desc).to_json only: [:id, :phone, :amount, :price, :state], include: :commodity
end

get '/buy_orders/:id' do |id|
	begin
		BuyOrder.find(id).to_json only: [:id, :phone, :amount, :price, :state], include: :commodity
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
    req['amount'].to_i.times do
      order = SellOrder.new
      order.price = req["price"]
      order.seller = req["seller"]
      order.commodity = commodity
      unless order.save
        halt 412, order.errors.full_messages
      end
    end
    match!
    halt 201
  rescue ActiveRecord::RecordNotFound
    halt 412, "Commodity not found"
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
    unless order.save
      halt 412, order.errors.full_messages
    end
    match!
    redirect '/buy_orders/' + order.id.to_s, 303
  rescue ActiveRecord::RecordNotFound
    halt 412, "Commodity not found"
  end 
end

put '/sell_orders/:id' do |id|
  auth
  req = ActiveSupport::JSON.decode(request.body)

  begin
    order = SellOrder.find(id)
    order.amount = req["amount"]
    order.price = req["price"]
    order.seller = req["seller"]
    unless order.save
      halt 412, order.errors.full_messages
    end
    match!
    redirect '/sell_orders/' + order.id.to_s, 200
  rescue ActiveRecord::RecordNotFound
    halt 404, "Order not found!"
  end
end
 
put '/buy_orders/:id' do |id|
  auth
  req = ActiveSupport::JSON.decode(request.body)

  begin
    order = BuyOrder.find(id)
    order.amount = req["amount"]
    order.price = req["price"]
    order.phone = req["phone"]
    unless order.save
      halt 412, order.errors.full_messages
    end
    match!
    redirect '/buy_orders/' + order.id.to_s, 200
  rescue ActiveRecord::RecordNotFound
    halt 404, "Order not found!"
  end
end

put '/buy_orders/:id/payment' do |id|
  auth
  begin
    order = BuyOrder.find(id)
    if order.state == "matched"
      order.state = :paid
      unless order.save
        halt 412, order.errors.full_messages
      end
    end
  rescue ActiveRecord::RecordNotFound
    halt 404, "Order not found!"
  end
  redirect '/buy_orders/' + id.to_s, 200
end

put '/commodities/:name' do |name|
  auth true
  req = ActiveSupport::JSON.decode(request.body)

  begin
    commodity = Commodity.where(:name => name).first!
    commodity.supply_rate = req["supply_rate"]
    commodity.supply_price = req["supply_price"]
    unless commodity.save
      halt 412, commodity.errors.full_messages
    end
  rescue ActiveRecord::RecordNotFound
    halt 404, "Commodity not found!"
  end
end

# Interface
get '/interface/barcom' do
  auth true
  haml :'interface/barcom'
end

get '/interface/buy_booth' do
  auth
	haml :'interface/buy_booth'
end

get '/interface/sell_booth' do
  auth
  haml :'interface/sell_booth'
end
