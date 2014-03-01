### Base class for API wrapper
class ApiWrapper
  attr_accessor :requests_limit, :time_limit
  attr_accessor :api_client, :use_queue

  def initialize(api_client)
    # Actual API client which handles real calls (probably separate GEM)
    @api_client = api_client

    # Should we use queue if rate limit exceeded
    @use_queue = true
  end

  def method_missing(method, *args, &block)
    raise NoMethodError unless @api_client.respond_to?(method)
    queue.call_or_enqueue(method, *args)
  end

  def name
    nil
  end

  # Run method on API client
  def call_method(method, *args)
    @api_client.public_send(method, *args)
  end

  def queue
    @queue ||= ApiCallQueue.new(self) 
  end
end
