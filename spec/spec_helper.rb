$:.unshift File.expand_path('../lib', __FILE__)
require 'imgshark'

RSpec.configure do |config|
  config.before(:each) do
    redis.flushall
  end
  
  # TODO use vcr
  
  def redis
    @redis ||= Redis.new()
  end
end