require "lita"
require 'lita/buildkite_build_finished_event'

module Lita
  module Handlers
    # Receives buildkite webhooks and emits them onto the lita event bus
    # so other handlers can do their thing
    class Buildkite < Handler

      http.post "/buildkite", :buildkite_event

      def buildkite_event(request, response)
        event = BuildkiteBuildFinishedEvent.new(request.body.read)
        robot.trigger(:buildkite_event, event: event)
      end

    end

    Lita.register_handler(Buildkite)
  end
end
