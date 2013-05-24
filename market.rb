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
# Spawn a thread to add supply for each commodity
Commodity.all.each do |commodity|
  @threads << Thread.new(commodity) do |commodity|
    while true
      commodity.reload

      # Do not add supply when no supply is set
      if commodity.supply_amount == 0 || commodity.supply_rate == 0
        sleep 1
        next
      end

      # Create a sell order
      SellOrder.create do |o|
        o.commodity = commodity
        o.price = commodity.supply_price
        o.seller = 'bar'
      end
      commodity.update_attribute(:supply_amount, commodity.supply_amount-1)
      log "Added one #{commodity['name']} for #{commodity['supply_price']}"

      # Sleep for the next adding
      sleep 60/commodity.supply_rate
    end
  end
end

# Spawn a thread to update bar_prices
@threads << Thread.new do
  prices = {}
  for commodity in Commodity.all
    prices[commodity.name] = commodity.rate + commodity.markup
  end

  while true
    if Setting.get('mode') == 'panic'
      # Calculate panic prices
      Commodity.all.each do |commodity|
        new_price = prices[commodity.name] + rand(-10..10)
        min_price = commodity.panic_price - commodity.panic_variance
        max_price = commodity.panic_price + commodity.panic_variance
        new_price = [[min_price, new_price].max, max_price].min
        prices[commodity.name] = new_price
        commodity.update_attribute :bar_price, prices[commodity.name].round(-1)
      end
    else
      # Calculate prices normally
      for commodity in Commodity.all
        cur = commodity.rate + commodity.markup
        prev = prices[commodity.name]

        newprice = cur > prev ? prev * 0.98 + cur * 0.02 : prev * 0.99 + cur * 0.01
        prices[commodity.name] = newprice
        commodity.update_column :bar_price, prices[commodity.name].round(-1)
      end
    end
    sleep 1
  end
end

# All done
log 'GONG! Markets are open'

# Keep application open till all threads are finished
@threads.each { |thr| thr.join }
