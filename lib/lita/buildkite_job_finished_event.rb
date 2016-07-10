require 'date'

# Value object that wraps raw buildkite webhook data and provides convenience
# methods for querying it
class BuildkiteJobFinishedEvent
  def initialize(data)
    @data = data
  end

  def name
    @data.fetch("event", "")
  end

  def job_name
    @data.fetch("job", {}).fetch("name","")
  end

  def job_state
    @data.fetch("job", {}).fetch("state","")
  end

  def job_started_at
    value = @data.fetch("job", {}).fetch("started_at", nil)
    value ? DateTime.parse(value) : nil
  end

  def job_finished_at
    value = @data.fetch("job", {}).fetch("finished_at", nil)
    value ? DateTime.parse(value) : nil
  end

  def agent_name
    @data.fetch("job", {}).fetch("agent",{}).fetch("name","")
  end

  def agent_hostname
    @data.fetch("job", {}).fetch("agent",{}).fetch("hostname","")
  end

  def build_branch
    @data.fetch("build", {}).fetch("branch","")
  end

  def pipeline_name
    @data.fetch("pipeline", {}).fetch("name", "")
  end
end
