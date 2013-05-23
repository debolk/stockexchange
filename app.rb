# Basic setup for every process
require 'bundler/setup'
require 'haml'
require 'sinatra'
require './sms.rb'
require './conf.rb'

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
    BuyOrder.open_orders.each do |buy_order|
      sell_orders = SellOrder.find_qualifying_orders(buy_order)
      if sell_orders.count == buy_order.amount
        # Match and log orders
        buy_order.match!(sell_orders)
        # Notify buyer
        send_sms(order)
      end
    end
  end

  def send_sms(order)
    return unless /316\d{8}/ =~ order.phone
    total_price = (order.total_value/100).round(2)
    SMS::notify order.phone, "Je order staat klaar: #{order.amount} #{order.commodity.name} voor #{total_price} euro. Haal 'm snel op bij het loket."
  end
end

# Broadcast special states of the market to all clients
before do
  return unless request.xhr?
  case Setting.get('mode')
  when 'panic'
    halt 503, 'Market panic'
  when 'closed'
    halt 503, 'Markets are closed'
  end
end

# REST API
get '/commodities' do
  if auth? admin: true
    Commodity.all.to_json only: [:id, :name, :supply_rate, :supply_price, :bar_price], methods: [:rate]
  else
    Commodity.all.to_json only: [:id, :name, :bar_price], methods: [:rate]
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
  commodity.buy_orders.where('state = ?', 'open').order('price DESC').each do |buy_order|
    if buy_order.amount > left
      total += buy_order.price * left
      left = 0
      break
    end
    total += buy_order.total_value
    left -= buy_order.amount
  end
  total += left*commodity.buyback_price
  halt 200, total.to_s
end

get '/buy_orders' do
  BuyOrder.where('state <> ?', 'paid').order('price DESC').to_json only: [:id, :phone, :amount, :price, :state], include: :commodity
end

get '/buy_orders/:id' do |id|
	begin
		BuyOrder.find(id).to_json only: [:id, :phone, :amount, :price, :state], include: :commodity
	rescue ActiveRecord::RecordNotFound
		halt 404, "Order not found!"
	end
end

get '/sell_orders' do
  SellOrder.order('price DESC').to_json only: [:id, :phone, :amount, :price], include: :commodity
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
      t = order.transaction
      t.buy_price = order.total_value
      t.save
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

post '/bar_order' do
  auth
  req = ActiveSupport::JSON.decode(request.body)
  req.each do |row|
    if row['amount'].to_i > 0
      commodity = Commodity.find(row['commodity_id'])
      b = BuyOrder.new do |b|
        b.commodity = commodity
        b.amount = row['amount'].to_i
        b.state = :matched
        b.price = commodity.bar_price
      end
      if b.valid?
        b.save
        sell_orders = SellOrder.order('price ASC').limit(row['amount'].to_i)
        sell_orders.update_all state: :matched

        t = Transaction.new
        t.commodity = b.commodity
        t.amount = b.amount
        t.buy_price = b.total_value
        t.sell_price = 0
        sell_orders.each do |s|
          t.sell_price += s.price
        end
        t.save
      else
        halt 500, b.errors.full_messages
      end
    end
  end
  halt 200
end

delete '/close' do
  auth true                   # Require authentication
  # Match all unmatched buy orders
  open_orders.each do |order|
    order.match! nil
    send_sms(order)
  end
  SellOrder.remove_all!       # Remove all unmatched sell orders
  Commodity.disable_supply!   # Disable all supply from the bar
  halt 200
end

delete '/panic' do
  auth true
  Setting.set('mode', 'panic')
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

get '/interface/barman' do
  auth
  haml :'interface/barman'
end

get '/' do
  haml :'interface/stats'
end

get '/interface/close' do
  auth true
  haml :'interface/close'
end

get '/interface/panic' do
  auth true
  haml :'interface/panic'
end