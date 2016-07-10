require "lita/buildkite"

describe Lita::Handlers::Buildkite, lita_handler: true do
  let(:handler) { Lita::Handlers::Buildkite.new(robot) }

  context "when buildkite sends a POST" do
    it "responds" do
      expect(handler).to route_http(:post, "/buildkite").to(:buildkite_event)
    end
  end

  describe "#buildkite_event" do
    let(:request) { double(body: double(read: event_json)) }
    let(:response) { double }

    before do
      allow(robot).to receive(:trigger)
    end

    context "with a build.finished event" do
      let(:json_path) { File.join(File.dirname(__FILE__), "fixtures", "buildkite_build_finished.json")}
      let(:event_json) { File.read(json_path) }

      it "emits a lita event" do
        handler.buildkite_event(request, response)
        expect(robot).to have_received(:trigger).with(:buildkite_build_finished, event: a_kind_of(BuildkiteBuildFinishedEvent))
      end
    end

    context "with a job.finished event" do
      let(:json_path) { File.join(File.dirname(__FILE__), "fixtures", "buildkite_job_finished.json")}
      let(:event_json) { File.read(json_path) }

      it "emits a lita event" do
        handler.buildkite_event(request, response)
        expect(robot).to have_received(:trigger).with(:buildkite_job_finished, event: a_kind_of(BuildkiteJobFinishedEvent))
      end
    end

    context "with an unrecognised event" do
      let(:event_json) { "{}" }

      it "does not emit a lita event" do
        handler.buildkite_event(request, response)
        expect(robot).to_not have_received(:trigger)
      end
    end
  end
end
