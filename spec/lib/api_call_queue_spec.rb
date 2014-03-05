require 'spec_helper'

describe ApiWrapper do

  before do
    @api_client = DummyFacebookApiClient.new
    @api = FacebookApi.new(@api_client)
    @queue = @api.queue
    @queue.redis = MockRedis.new
  end

  describe '#rate_limit_exceeded?' do
    
    it 'should return false if call_counter is less than api requests limit' do
      @queue.redis.set('facebook_call_counter', 100)
      @queue.rate_limit_exceeded?.should be_false
    end

    it 'should return true if call_counter is greater than api requests limit and time limit not passed' do
      @queue.redis.set('facebook_call_counter', 1000)
      @queue.redis.set('facebook_first_usage', 100.seconds.ago)
      @queue.rate_limit_exceeded?.should be_true
    end

    it 'should return false if call_counter is greater than api requests limit and time limit passed' do
      @queue.redis.set('facebook_call_counter', 1000)
      @queue.redis.set('facebook_first_usage', 1000.seconds.ago)
      @queue.rate_limit_exceeded?.should be_false
    end
  end


  describe '#call_or_enqueue' do

    it 'should run first 600 requests and enqueue other' do
      redis_queue = double()
      redis_queue.stub(:push).and_return(true)
      ApiCallQueue.any_instance.stub(:redis_queue).and_return(redis_queue)

      (@api.requests_limit + 10).times do |i|
        @queue.call_or_enqueue('do_something', i).should == (i < @api.requests_limit  ? "result #{i}" : :enqueued)
      end
    end

    context 'without rate limit exceeded' do

      before { ApiCallQueue.any_instance.stub(:rate_limit_exceeded?).and_return(false) }

      it 'should run method if rate limit not exceeded' do
        @queue.call_or_enqueue('do_something', '1').should == 'result 1'
      end
    end

    context 'with rate limit exceeded' do

      before { ApiCallQueue.any_instance.stub(:rate_limit_exceeded?).and_return(true) }

      it 'should raise RateLimitExceeced if rate limit exceeded and queue should not be use' do
        @api.use_queue = false
        expect { @queue.call_or_enqueue('do_something', '1') }.to raise_error(RateLimitExceeced)
      end

      it 'should enqueue method call if rate limit exceeded and queue should be use' do
        ApiCallQueue.any_instance.stub(:enqueue).and_return(true) 
        @queue.call_or_enqueue('do_something', '1').should == :enqueued
      end
    end
  end
end
