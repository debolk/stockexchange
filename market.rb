# Starts all services required
require './setup'

print 'Starting market interface servers...'
system 'thin start > /dev/null &'
puts 'done'

print 'Loading market software...'
class Market
end
market = Market.new
puts 'done'

print 'Initializing market heartbeat...'
threads = []
threads << Thread.new do
  while true
    puts 'beep'
    sleep 1
  end
end
puts 'done'

puts 'GONG! Markets are open'
puts ''
threads.each { |thr| thr.join }