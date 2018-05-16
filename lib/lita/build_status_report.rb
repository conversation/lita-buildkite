class BuildStatusReport
  def initialize(event, days_since_last_failure, prev_days_since_last_failure, most_successful_days)
    @event = event
    @days_since_last_failure = days_since_last_failure
    @prev_days_since_last_failure = prev_days_since_last_failure
    @most_successful_days = most_successful_days

    yield message if message
  end

  private

  def message
    @message ||= begin
      if @days_since_last_failure > @prev_days_since_last_failure
        "#{@event.pipeline} is #{@days_since_last_failure} days without a failure"
      elsif @days_since_last_failure < @prev_days_since_last_failure
        if @prev_days_since_last_failure >= @most_successful_days
          "#{@event.pipeline} ended it's record breaking run of #{@prev_days_since_last_failure} days without a failure 😢"
        else
          "#{@event.pipeline} failed after #{@prev_days_since_last_failure} days, previous best was #{@most_successful_days}"
        end
      end
    end
  end
end
