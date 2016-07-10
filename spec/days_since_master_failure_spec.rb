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
          build: {
            finished_at: "2016-03-22 12:00:00",
            branch: "master",
            state: "failed"
          },
          pipeline: {
            name: "tc"
          }
        }.to_json
      }

      context "we've never reported a result" do
        before do
          allow(repository).to receive(:record_result).and_yield(0,0)
        end

        it "should not send any messages" do
          handler.timestamp_failure(payload)
          expect(robot).to_not have_received(:send_message)
        end
      end

      context "the days since last failure has gone up to 1" do
        before do
          allow(repository).to receive(:record_result).and_yield(1,0)
        end

        it "should send a message" do
          handler.timestamp_failure(payload)
          expect(robot).to_not have_received(:send_message).with(
            a_kind_of(Lita::Room),
            "Congratulations! 1 day(s) since the last master failure"
          )
        end
      end
      context "the days since last failure has gone down to 0" do
        before do
          allow(repository).to receive(:record_result).and_yield(0, 1)
        end

        it "should send a message" do
          handler.timestamp_failure(payload)
          expect(robot).to_not have_received(:send_message).with(
            a_kind_of(Lita::Room),
            "Oh Oh! 0 day(s) since the last master failure"
          )
        end
      end
    end
  end
end
