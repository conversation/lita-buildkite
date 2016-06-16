require "lita"
require 'lita/buildkite_event'
require 'lita/days_since_master_failure_repository'

module Lita
  module Handlers
    # Watch buildkite webhooks for build failures of the master branch, and track
    # how long the team can go without a failure
    class DaysSinceMasterFailure < Handler
      config :channel_name

      on :buildkite_event, :timestamp_failure

      def timestamp_failure(payload)
        event = payload[:event]

        if event.branch == "master" && event.build_finished?
          process_build_finished(event) do |msg|
            robot.send_message(target, msg)
          end
        end
      end

      private

      def process_build_finished(event, &block)
        repository = DaysSinceMasterFailureRepository.new(redis, event.pipeline)
        repository.record_result(event.passed?) do |days_since_last_failure, prev_days_since_last_failure|
          if days_since_last_failure < prev_days_since_last_failure
            yield "Oh Oh, #{days_since_last_failure} day(s) since the last master failure on #{event.pipeline}"
          elsif days_since_last_failure > prev_days_since_last_failure
            yield "Congratulations! #{days_since_last_failure} day(s) since the last master failure on #{event.pipeline}"
          end
        end
      end

      def target
        Source.new(room: Lita::Room.find_by_name(config.channel_name) || "general")
      end

    end

    Lita.register_handler(DaysSinceMasterFailure)
  end
end
