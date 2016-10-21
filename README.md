# lita-buildkite

A lita plugin for interacting with buildkite.com, a Continuous Integration provider.

## Installation

Add this gem to your lita installation by including the following line in your Gemfile:

    gem "lita-buildkite"

## Externally triggered events

This handler can track completed builds and trigger a variety of activities as appropriate. To
get started, use the buildkite web interface to configure a webhook that POSTs "build.finished"
events to:

    http://your-lita-bot.com/buildkite

### Days Since Master Failure

To track how long each project has managed to go without a master branch failure, edit your
lita\_config.rb to include the following line. 

    config.handlers.days_since_master_failure.channel_name = "channel-name"

As builds complete, occasional messages will be posted to the channel that congratulate for
a string of days with no failures, and commiserate when a master branch build fails.

## Chat commands

This handler provides no additional chat commands. Yet.

## Lita Events

This handler will emit some buildkite events onto the lita event bus, allowing other handlers
to respond them.

Currently, the following events are emitted:

* buildkite\_build\_finished
* buildkite\_job\_finished

To respond to the events, write a new handler that looks something like this:

    class BuildkiteDebugHandler < Lita::Handlers::Handler
      on :buildkite_build_finished, :debug
      on :buildkite_job_finished, :debug

      def debug(payload)
        event = payload[:event]

        robot.send_message(target, event.inspect)
      end

      private

      def target
        Source.new(room: Lita::Room.find_by_name(config.channel_name) || "general")
      end
    end

## TODO

Possible ideas for new features, either via chat commands or externally triggered events:

* more specs
