require 'date'

# Value object that wraps raw buildkite webhook data and provides convenience
# methods for querying it
class BuildkiteBuildFinishedEvent
  def initialize(data)
    @data = data
  end

  def name
    @data.fetch("event", "")
  end

  # deprecated
  def branch
    build_branch
  end

  # deprecated
  def pipeline
    pipeline_name
  end

  def pipeline_name
    @data.fetch("pipeline", {}).fetch("name", "")
  end

  def pipeline_slug
    @data.fetch("pipeline", {}).fetch("slug", "")
  end

  def passed?
    @data.fetch("build", {}).fetch("state", "") == "passed"
  end

  def build_branch
    @data.fetch("build", {}).fetch("branch", "")
  end

  def build_created_at
    value = @data.fetch("build", {}).fetch("created_at", nil)
    value ? DateTime.parse(value).to_time : nil
  end

  def build_started_at
    value = @data.fetch("build", {}).fetch("started_at", nil)
    value ? DateTime.parse(value).to_time : nil
  end

  def build_finished_at
    value = @data.fetch("build", {}).fetch("finished_at", nil)
    value ? DateTime.parse(value).to_time : nil
  end
end
