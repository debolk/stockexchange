# Starts all services required
require './setup'

print 'Starting market interface servers...'
system 'thin start > /dev/null &'
puts 'done'

print 'Initializing market heartbeat...'
threads = []
semaphore = Mutex.new
Commodity.all.each do |commodity|
  threads << Thread.new(commodity.name) do |name|
    while true
      semaphore.synchronize {
        puts name
      }
      sleep 1
    end
  end
end
puts 'done'

puts 'GONG! Markets are open'
puts ''
threads.each { |thr| thr.join }
while true
  sleep 1
end