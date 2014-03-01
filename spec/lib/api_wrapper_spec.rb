require 'spec_helper'

describe ApiWrapper do

  before do
    @api_client = DummyFacebookApiClient.new
    @api = ApiWrapper.new(@api_client)
  end

  it 'should use queue by default' do
    @api.use_queue.should be_true
  end

  it 'should have queue' do
    @api.queue.should be_instance_of(ApiCallQueue)
  end

  it 'should raise NoMethodError if api_client not responding to method' do
    expect { @api.other_method('test') }.to raise_error(NoMethodError)
  end

  it 'should call api_client method if exists' do
    ApiCallQueue.any_instance.stub(:rate_limit_exceeded?).and_return(false)
    ApiCallQueue.any_instance.stub(:increment_api_usage_counter).and_return(true)

    @api.do_something('test').should == 'result test' 
  end
end
