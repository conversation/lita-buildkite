require 'lita/buildkite_build_finished_event'
require 'json'

describe BuildkiteBuildFinishedEvent do
  let(:json_path) { File.join(File.dirname(__FILE__), "fixtures", "buildkite_build_finished.json")}
  let(:json) { JSON.load(File.read(json_path)) }
  let(:event) { BuildkiteBuildFinishedEvent.new(json)}

  describe '.name' do
    it "returns the correct value" do
      expect(event.name).to eq "build.finished"
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
