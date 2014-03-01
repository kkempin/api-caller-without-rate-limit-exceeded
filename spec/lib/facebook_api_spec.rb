require 'spec_helper'

describe FacebookApi do

  let(:api) { FacebookApi.new(DummyFacebookApiClient.new) }
  
  it 'should be named facebook' do
    api.name.should == 'facebook'
  end

  it 'should have requests limit' do
    api.requests_limit.should == 600
  end

  it 'should have time limit' do
    api.time_limit.should == 600.seconds
  end

end
