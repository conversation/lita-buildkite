require 'lita/buildkite_build_finished_event'
require 'lita/buildkite_unknown_event'
require 'json'

class BuildkiteEvent
  def self.build(string)
    data = JSON.load(string)

    case data.fetch("event", "")
    when "build.finished" then
      BuildkiteBuildFinishedEvent.new(data)
    else
      BuildkiteUnknownEvent.new(data)
    end
  end
end
