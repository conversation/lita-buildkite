require "lita/build_status_report"
require "lita/buildkite_job_finished_event"

RSpec.describe BuildStatusReport do
  let(:event) { instance_double(BuildkiteBuildFinishedEvent, pipeline: "tc") }

  describe ".new" do
    context "days_since_last_failure and prev_days_since_last_failure are equal" do
      it "yields nothing" do
        expect { |b|
          BuildStatusReport.new(event, 1, 1, 0, &b)
        }.not_to yield_control
      end
    end

    context "days_since_last_failure greater than prev_days_since_last_failure" do
      let(:days_since_last_failure) { 2 }
      let(:prev_days_since_last_failure) { 1 }
      let(:most_successful_days) { 0 }

      it "yields a happy message" do
        expect { |b|
          BuildStatusReport.new(event, days_since_last_failure, prev_days_since_last_failure, most_successful_days, &b)
        }.to yield_with_args("tc is 2 days without a failure")
      end
    end

    context "days_since_last_failure less than prev_days_since_last_failure" do
      let(:days_since_last_failure) { 0 }
      let(:prev_days_since_last_failure) { 2 }

      context "prev_days_since_last_failure greater than most_successful_days" do
        let(:most_successful_days) { 0 }

        it "yields a sad message" do
          expect { |b|
            BuildStatusReport.new(event, days_since_last_failure, prev_days_since_last_failure, most_successful_days, &b)
          }.to yield_with_args("tc ended it's record breaking run of 2 days without a failure 😢")
        end
      end

      context "prev_days_since_last_failure less than most_successful_days" do
        let(:most_successful_days) { 3 }

        it "yields a sad message" do
          expect { |b|
            BuildStatusReport.new(event, days_since_last_failure, prev_days_since_last_failure, most_successful_days, &b)
          }.to yield_with_args("tc failed after 2 days, previous best was 3")
        end
      end
    end
  end
end
