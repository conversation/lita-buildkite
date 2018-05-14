require "lita/build_status_report"
require "lita/buildkite_job_finished_event"

RSpec.describe BuildStatusReport do
  let(:event) { instance_double(BuildkiteBuildFinishedEvent, pipeline: "tc") }

  describe ".new" do
    context "days_since_last_failure and prev_days_since_last_failure are equal" do
      it "yields nothing" do
        expect { |b|
          BuildStatusReport.new(event, 1, 1, &b)
        }.not_to yield_control
      end
    end

    context "days_since_last_failure less than prev_days_since_last_failure" do
      it "yields a happy message" do
        expect { |b|
          BuildStatusReport.new(event, 1, 0, &b)
        }.to yield_with_args("tc is 1 day(s) without a failure!")
      end
    end

    context "days_since_last_failure greater than prev_days_since_last_failure" do
      it "yields a sad message" do
        expect { |b|
          BuildStatusReport.new(event, 0, 1, &b)
        }.to yield_with_args("tc failed after 1 day(s)")
      end
    end
  end
end
