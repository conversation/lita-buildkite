require "lita"
require 'lita/buildkite_event'
require 'lita/buildkite_build_finished_event'

module Lita
  module Handlers
    # Receives buildkite webhooks and emits them onto the lita event bus
    # so other handlers can do their thing
    class Buildkite < Handler

      http.post "/buildkite", :buildkite_event

      def buildkite_event(request, response)
        event = BuildkiteEvent.build(request.body.read)
        case event
        when BuildkiteBuildFinishedEvent 
          robot.trigger(:buildkite_build_finished, event: event)
        else
          puts "UnsupportedEvent: #{event.class}"
        end
      end

    end

    Lita.register_handler(Buildkite)
  end
end
