# Provides all persistence logic for the DaysSinceMasterFailure handler, insulating
# the handler from any knowledge of redis
class DaysSinceMasterFailureRepository
  def initialize(redis)
    @redis = redis

    initialise_last_failure_at_if_not_set
  end

  def record_result(success, &block)
    touch_last_failure_at if !success
    yield days_since_last_failure, last_reported_days
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
    @redis.set("last-failure-at", ::Time.now.to_i)
  end

  def touch_last_reported_days
    set_last_reported_days(days_since_last_failure)
  end

  def fetch_last_failure_at
    @redis.get("last-failure-at").to_i
  end

  def set_last_reported_days(days)
    @redis.set("last-reported-days", days.to_i)
  end

  def last_reported_days
    @redis.get("last-reported-days").to_i
  end

  def initialise_last_failure_at_if_not_set
    @redis.setnx("last-failure-at", ::Time.now.to_i)
  end
end
