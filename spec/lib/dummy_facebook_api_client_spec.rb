require 'spec_helper'

describe DummyFacebookApiClient do

  let(:api_client) { DummyFacebookApiClient.new }
  
  it 'should return result' do
    result = api_client.do_something(1)
    result.should == 'result 1'
  end

end
