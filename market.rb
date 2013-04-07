require 'net/http'
require 'json'

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
system 'thin start > /dev/null 2>/dev/null &'
sleep 2
log 'done'

# Threads to update market
log 'Initializing market heartbeat...', false
@@threads = []
# Get all commodities
def get_commodities
  uri = URI('http://localhost:3000/commodities?110F4B0BDF366C453723')
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end
commodities = get_commodities
# Spawn a heartbeat for each commodity
commodities.each do |commodity|
  @@threads << Thread.new(commodity) do |commodity|
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
@@threads << Thread.new do
  while true
    for commodity in get_commodities
      for old in commodities
        if old['name'] == commodity['name']
          old
        end
      end
    end
    sleep 15
  end
end
# Keep application open till all threads are finished
@@threads.each { |thr| thr.join }
log 'done'

# All done
log 'GONG! Markets are open'

