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

  def job_slug
    slugorize(job_name)
  end

  def job_state
    @data.fetch("job", {}).fetch("state","")
  end

  def job_started_at
    value = @data.fetch("job", {}).fetch("started_at", nil)
    value ? DateTime.parse(value).to_time : nil
  end

  def job_finished_at
    value = @data.fetch("job", {}).fetch("finished_at", nil)
    value ? DateTime.parse(value).to_time : nil
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

  def pipeline_slug
    @data.fetch("pipeline", {}).fetch("slug", "")
  end

  private

  def slugorize(input)
    result = input.to_s.downcase
    result.gsub!(/['|’]/, '')           # Remove apostrophes
    result.gsub!('&', 'and')            # Replace & with 'and'
    result.gsub!(/[^a-z0-9\-]/, '-')    # Get rid of anything we don't like
    result.gsub!(/-+/, '-')             # collapse dashes
    result.gsub!(/-$/, '')              # trim dashes
    result.gsub!(/^-/, '')              # trim dashes
    result
  end
end
