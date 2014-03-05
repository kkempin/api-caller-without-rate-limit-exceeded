require './environment'

fb_api_client = DummyFacebookApiClient.new
fb_api = FacebookApi.new(fb_api_client)

# Very, very simple example of some script which will run on server and will check if there is something in
# queue to pop (unless rate limit exceeded) and run.
# Alternatively we can use http://daemons.rubyforge.org/ , simple ruby loop or something like this
api_worker = ApiWorker.new
api_worker.register_api(fb_api)
api_worker.process


700.times{|i| fb_api.do_something(i)}
