require "lita"
require 'lita/buildkite_build_finished_event'
require 'lita/days_since_master_failure_repository'

module Lita
  module Handlers
    # Watch buildkite webhooks for build failures of the master branch, and track
    # how long the team can go without a failure
    class DaysSinceMasterFailure < Handler
      config :channel_name

      on :buildkite_build_finished, :timestamp_failure

      def timestamp_failure(payload)
        event = payload[:event]

        if event.branch == "master" && event.name == "build.finished"
          process_build_finished(event) do |msg|
            robot.send_message(target, msg)
          end
        end
      end

      private

      def process_build_finished(event, &block)
        repository(event).record_result(event) do |message|
          yield message
        end
      end

      def repository(event)
        DaysSinceMasterFailureRepository.new(redis, event.pipeline)
      end

      def target
        Source.new(room: Lita::Room.find_by_name(config.channel_name) || "general")
      end

    end

    Lita.register_handler(DaysSinceMasterFailure)
  end
end
