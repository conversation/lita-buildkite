class BuildStatusReport
  def initialize(event, days_since_last_failure, prev_days_since_last_failure)
    @event = event
    @days_since_last_failure = days_since_last_failure
    @prev_days_since_last_failure = prev_days_since_last_failure

    yield message if message
  end

  private

  def message
    @message ||= begin
      if @days_since_last_failure < @prev_days_since_last_failure
        "#{@event.pipeline} failed after #{@prev_days_since_last_failure} day(s)"
      elsif @days_since_last_failure > @prev_days_since_last_failure
        "#{@event.pipeline} is #{@days_since_last_failure} day(s) without a failure!"
      end
    end
  end
end
