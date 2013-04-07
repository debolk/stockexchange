# Starts all services required
require './setup'
@@semaphore = Mutex.new
@@threads = []
# Utility functions
def self.log(text, new_line = true)
  @@semaphore.synchronize do
    if new_line
      puts text
    else
      print text
    end
  end
end

log 'Starting market interface servers...', false
system 'thin start > /dev/null &'
log 'done'

log 'Initializing market heartbeat...', false
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

log 'GONG! Markets are open'

