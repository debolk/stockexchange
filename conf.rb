require "sinatra/activerecord"
require 'acts_as_paranoid'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  database: 'stockexchange',
  host:     'stockexchange.i.bolkhuis.nl',
  username: 'stockexchange',
  password: 'DCavLcCXrBVyRBJq'
)
ActiveRecord::Base.include_root_in_json = false

require './models/buyorder.rb'
require './models/sellorder.rb'
require './models/commodity.rb'
require './models/transaction.rb'

