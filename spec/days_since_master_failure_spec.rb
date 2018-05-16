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

      context "record_result yields a message" do
        before do
          allow(repository).to receive(:record_result).and_yield("message")
        end

        it "sends a message" do
          handler.timestamp_failure(payload)
          expect(robot).to have_received(:send_message).with(
            an_instance_of(Lita::Source), "message"
          )
        end
      end

      context "record_result does not yield a message" do
        before do
          allow(repository).to receive(:record_result)
        end

        it "does not send any messages" do
          handler.timestamp_failure(payload)
          expect(robot).to_not have_received(:send_message)
        end
      end
    end
  end
end
