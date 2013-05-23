require 'net/http'
require 'json'

require './conf.rb'

# Logging
@semaphore = Mutex.new
def self.log(text, new_line = true)
  @semaphore.synchronize do
    if new_line
      puts text
    else
      print text
    end
  end
end

# Interface servers
log 'Starting market interface servers...', false
system 'thin start > /dev/null 2>/dev/null &'
sleep 2
log 'done'

# Threads to update market
log 'Initializing market heartbeat...done'

# Show all errors
Thread.abort_on_exception = true

@threads = []
# Function to retrieve all updated commoditiesfa
def get_commodities
  uri = URI('http://localhost:3000/commodities?110F4B0BDF366C453723')
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end
@commodities = get_commodities
# Spawn a heartbeat for each commodity
@commodities.each do |commodity|
  @threads << Thread.new(commodity) do |commodity|
    while true
      while commodity['supply_rate'].to_i == 0
        sleep 1
      end
      data = {
        commodity: commodity['name'],
        amount: 1,
        price: commodity['supply_price'],
        seller: 'bar',
      }
      http = Net::HTTP.new('localhost', '3000')
      request = Net::HTTP::Post.new('/sell_orders?110F4B0BDF366C453723')
      request.body = data.to_json
      request["Content-Type"] = "application/json"
      response = http.request(request)
      log "Added one #{commodity['name']} for #{commodity['supply_price']}"
      if commodity['supply_rate'].to_i == 0
        sleep 1
      else  
        sleep 60/commodity['supply_rate']
      end
    end
  end
end
# Spawn a thread to update commodities
@threads << Thread.new do
  while true
    for commodity in get_commodities
      for old in @commodities
        if old['name'] == commodity['name']
          old['supply_rate'] = commodity['supply_rate'] 
          old['supply_price'] = commodity['supply_price']
          old['bar_price'] = commodity['bar_price']
        end
      end
    end
    log 'Commodities updated'
    sleep 3
  end
end

# Spawn a thread to update bar_prices
@threads << Thread.new do
  prices = {}
  for commodity in Commodity.all
    prices[commodity.name] = commodity.rate + commodity.markup
  end

  while true
    for commodity in Commodity.all
      cur = commodity.rate + commodity.markup
      prev = prices[commodity.name]

      newprice = cur > prev ? prev * 0.98 + cur * 0.02 : prev * 0.99 + cur * 0.01
      prices[commodity.name] = newprice
      commodity.update_column :bar_price, prices[commodity.name].round(-1)
    end
    sleep 1
  end
end

# All done
log 'GONG! Markets are open'

# Keep application open till all threads are finished
@threads.each { |thr| thr.join }
