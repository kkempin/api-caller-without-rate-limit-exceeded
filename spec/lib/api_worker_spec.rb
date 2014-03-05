require 'spec_helper'

describe ApiWrapper do

  before do
    @api_client = DummyFacebookApiClient.new
    @api = FacebookApi.new(@api_client)
    @queue = @api.queue
    @queue.redis = MockRedis.new
    @worker = ApiWorker.new
    @worker.register_api(@api)
  end

  describe '#register_api' do
    
    it 'should saves registered APIs' do
      @worker.apis.should == [@api]
    end
  end

  describe '#process' do

    before do
      @worker.stop!
      redis_queue = double()
      encoded_request = ['do_something', '1'].to_json
      $flag = 0
      # return requets only for first loop rub
      redis_queue.stub(:pop).and_return(encoded_request)
      redis_queue.stub(:commit)
      ApiCallQueue.any_instance.stub(:redis_queue).and_return(redis_queue)
      ApiCallQueue.any_instance.stub(:rate_limit_exceeded?).and_return(false)
      DummyFacebookApiClient.any_instance.stub(:do_something) do
        $flag = 1
      end
    end

    it 'should run request from queue if it appears and rate limit is not exceeded' do
      @worker.process
      $flag.should == 1 
    end
  end
end
