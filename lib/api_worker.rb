### Worker class to process queue
class ApiWorker
  
  attr_accessor :apis, :should_stop

  def initialize
    @apis = []
    @should_stop = false
  end

  def register_api(api)
    @apis << api
  end

  def stop!
    @should_stop = true
  end

  def process
    # process queue
    loop do
      @apis.each do |api|
        queue = api.queue
        unless api.queue.rate_limit_exceeded?
          if obj = queue.pop
            begin
              method_data = JSON.parse(obj)
              queue.run(method_data.first, *method_data[1..-1])
              queue.commit
            rescue => e
              # TODO: exceptions handling
              puts e
              nil
            end
          end
        end
      end

      break if @should_stop
    end
  end

end
