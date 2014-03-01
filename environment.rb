Bundler.require(:default)
Dir[Dir.pwd + "/lib/*.rb"].each { |f| require f }

require 'active_support/all'
require 'time'

$redis = Redis.new
