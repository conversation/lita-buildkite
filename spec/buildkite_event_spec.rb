require 'lita/buildkite_event'
require 'json'

describe BuildkiteEvent do
  let(:json_path) { File.join(File.dirname(__FILE__), "fixtures", "buildkite_build_finished.json")}
  let(:json) { File.read(json_path) }
  let(:event) { BuildkiteEvent.new(json)}

  describe '.build_finished?' do
    it "returns true" do
      expect(event.build_finished?).to eq true
    end
  end

  describe '.branch' do
    it "returns the branch name" do
      expect(event.branch).to eq "master"
    end
  end

  describe '.pipeline' do
    it "returns the pipeline name" do
      expect(event.pipeline).to eq "pipeline-name"
    end
  end

  describe '.passed?' do
    it "returns true" do
      expect(event.passed?).to eq true
    end
  end
end
