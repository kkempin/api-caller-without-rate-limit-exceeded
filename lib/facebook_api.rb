### Facebook API wrapper
class FacebookApi < ApiWrapper

  def initialize(api_client)
    @requests_limit = 600
    @time_limit = 600.seconds
    super
  end

  def name
    'facebook'
  end
end
