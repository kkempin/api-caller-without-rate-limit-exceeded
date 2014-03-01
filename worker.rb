require 'environment'

fb_api_client = DummyFacebookApiClient.new
api = FacebookApi.new(fb_api_client)

# Very, very simple example of some script which will run on server and will check if there is something in
# queue to pop (unless rate limit exceeded) and run.
# Alternatively we can use http://daemons.rubyforge.org/ , simple ruby loop or something like this
#api.queue.process


700.times{|i| api.do_something(i)}
