require 'json'

# Value object that wraps raw buildkite webhook data and provides convenience
# methods for querying it
class BuildkiteEvent
  def initialize(data)
    @data = JSON.load(data)
  end

  def name
    @data.fetch("event", "")
  end

  def build_finished?
    @data.fetch("build", {}).fetch("finished_at", "") != ""
  end

  def branch
    @data.fetch("build", {}).fetch("branch", "")
  end

  def pipeline
    @data.fetch("pipeline", {}).fetch("name", "")
  end

  def passed?
    @data.fetch("build", {}).fetch("state", "") == "passed"
  end
end
