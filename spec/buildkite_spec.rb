require "lita/buildkite"

describe Lita::Handlers::Buildkite, lita_handler: true do
  let(:handler) { Lita::Handlers::Buildkite.new(robot) }

  context "when buildkite sends a POST" do
    it "responds" do
      expect(handler).to route_http(:post, "/buildkite").to(:buildkite_event)
    end
  end

  describe "#buildkite_event" do
    let(:request) { double(body: double(read: "{}")) }
    let(:response) { double }

    before do
      allow(robot).to receive(:trigger)
    end

    it "emits a lita event" do
      handler.buildkite_event(request, response)
      expect(robot).to have_received(:trigger).with(:buildkite_event, event: a_kind_of(BuildkiteEvent))
    end
  end
end
