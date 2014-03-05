class RateLimitExceeced < StandardError
end

### Queue for API calls
class ApiCallQueue

  attr_accessor :api, :redis

  def initialize(api)
    @api = api
    @redis = $redis
  end

  def call_or_enqueue(method, *args)
    if rate_limit_exceeded?
      if @api.use_queue
        enqueue(method, *args)
        # if API call is enqueued, we return flag to show this fact
        return :enqueued
      else
        raise RateLimitExceeced
      end
    else
      run(method, *args)
    end
  end 

  def rate_limit_exceeded?
    (call_counter >= @api.requests_limit) && 
      (first_usage + @api.time_limit > Time.now)
  end

  def run(method, *args)
    results = nil
    begin
      results = @api.call_method(method, *args)
    ensure
      # even if method run on API client fails, we should increase API usage counter
      increment_api_usage_counter
    end

    results
  end

  def pop
    redis_queue.pop(true)
  end

  def commit
    redis_queue.commit
  end

  private

  def enqueue(method, *args)
    redis_queue.push([method, *args].to_json)
  end 

  def increment_api_usage_counter
    first_usage = Time.parse(@redis.get("#{@api.name}_first_usage") || Time.now.to_s)
    call_counter = (@redis.get("#{@api.name}_call_counter") || 0).to_i

    if first_usage + @api.time_limit < Time.now
      first_usage = Time.now
      call_counter = 1
    else
      call_counter += 1
    end

    @redis.multi do
      @redis.set("#{@api.name}_first_usage", first_usage)
      @redis.set("#{@api.name}_call_counter", call_counter)
    end
  end

  def call_counter
    (@redis.get("#{@api.name}_call_counter") || 0).to_i
  end

  def first_usage
    Time.parse(@redis.get("#{@api.name}_first_usage") || Time.now.to_s)
  end

  def redis_queue
    @redis_queue ||= Redis::Queue.new(@api.name, "bp_#{@api.name}",  redis: $redis)
  end
end
