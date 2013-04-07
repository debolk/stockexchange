# Starts all services required
require './setup'

print 'Starting market interface servers...'
system 'thin start > /dev/null &'
puts 'done'
