require 'lita/build_status_report'

# Provides all persistence logic for the DaysSinceMasterFailure handler, insulating
# the handler from any knowledge of redis
class DaysSinceMasterFailureRepository
  def initialize(redis, pipeline_name)
    @redis = redis
    @last_failure_key = "last-failure-at-#{pipeline_name}"
    @last_reported_days_key = "last-reported-days-#{pipeline_name}"

    initialise_last_failure_at_if_not_set
  end

  def record_result(event, &block)
    touch_last_failure_at if !event.passed?

    BuildStatusReport.new(event, days_since_last_failure, last_reported_days) do |message|
      yield message
    end

    touch_last_reported_days
  end

  private

  def seconds_to_days(secs)
    secs.to_i / 60 / 60 / 24
  end

  def days_since_last_failure
    seconds_to_days(::Time.now.to_i - fetch_last_failure_at)
  end

  def touch_last_failure_at
    @redis.set(@last_failure_key, ::Time.now.to_i)
  end

  def touch_last_reported_days
    set_last_reported_days(days_since_last_failure)
  end

  def fetch_last_failure_at
    @redis.get(@last_failure_key).to_i
  end

  def set_last_reported_days(days)
    @redis.set(@last_reported_days_key, days.to_i)
  end

  def last_reported_days
    @redis.get(@last_reported_days_key).to_i
  end

  def initialise_last_failure_at_if_not_set
    @redis.setnx(@last_failure_key, ::Time.now.to_i)
  end
end
