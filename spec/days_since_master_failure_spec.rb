require "lita/days_since_master_failure"

describe Lita::Handlers::DaysSinceMasterFailure, lita_handler: true do
  let(:handler) { Lita::Handlers::DaysSinceMasterFailure.new(robot) }

  describe "#timestamp_failure" do
    let(:event) { BuildkiteBuildFinishedEvent.new(event_json)}
    let(:payload) { {event: event} }
    let(:repository) { instance_double(DaysSinceMasterFailureRepository) }

    before do
      allow(robot).to receive(:send_message)
      allow(handler).to receive(:repository).and_return(repository)
    end

    context "a master build failed" do
      let(:event_json) {
        {
          "event" => "build.finished",
          "build" => {
            "finished_at" => "2016-03-22 12:00:00",
            "branch" => "master",
            "state" => "failed"
          },
          "pipeline" => {
            "name" => "tc"
          }
        }
      }

      context "days_since_last_failure and prev_days_since_last_failure are equal" do
        before do
          allow(repository).to receive(:record_result).and_yield(0,0)
        end

        it "does not send any messages" do
          handler.timestamp_failure(payload)
          expect(robot).to_not have_received(:send_message)
        end
      end

      context "days_since_last_failure is greater than prev_days_since_last_failure" do
        before do
          allow(repository).to receive(:record_result).and_yield(1,0)
        end

        it "sends a message" do
          handler.timestamp_failure(payload)
          expect(robot).to have_received(:send_message).with(
            an_instance_of(Lita::Source),
            "Congratulations! 1 day(s) since the last master failure on tc"
          )
        end
      end
      context "days_since_last_failure is less than prev_days_since_last_failure" do
        before do
          allow(repository).to receive(:record_result).and_yield(0, 1)
        end

        it "sends a message" do
          handler.timestamp_failure(payload)
          expect(robot).to have_received(:send_message).with(
            an_instance_of(Lita::Source),
            "Oh Oh, 0 day(s) since the last master failure on tc"
          )
        end
      end
    end
  end
end
