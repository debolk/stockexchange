require './setup'

# Logging
@@semaphore = Mutex.new
def self.log(text, new_line = true)
  @@semaphore.synchronize do
    if new_line
      puts text
    else
      print text
    end
  end
end

# Interface servers
log 'Starting market interface servers...', false
system 'thin start > /dev/null &'
log 'done'

# Threads to update market
log 'Initializing market heartbeat...', false
@@threads = []
Commodity.all.each do |commodity|
  @@threads << Thread.new(commodity) do |commodity|
    while true
      commodity.reload
      SellOrder.create(commodity: commodity, seller: 'bar', amount: commodity.price)
      sleep(60/commodity.supply_rate)
    end
  end
end
log 'done'
@@threads.each { |thr| thr.join }

# All done
log 'GONG! Markets are open'

