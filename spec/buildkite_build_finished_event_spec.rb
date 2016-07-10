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

  describe '.build_branch' do
    it "returns the branch name" do
      expect(event.branch).to eq "master"
    end
  end

  describe '.pipeline' do
    it "returns the pipeline name" do
      expect(event.pipeline).to eq "pipeline-name"
    end
  end

  describe '.pipeline_name' do
    it "returns the pipeline name" do
      expect(event.pipeline).to eq "pipeline-name"
    end
  end

  describe '.pipeline_slug' do
    it "returns the pipeline name" do
      expect(event.pipeline_slug).to eq "pipeline-name"
    end
  end

  describe '.passed?' do
    it "returns true" do
      expect(event.passed?).to eq true
    end
  end

  describe 'build_created_at' do
    it "returns correct time" do
      expect(event.build_created_at).to eq Time.utc(2016,3,20,9,46,52)
    end
  end

  describe 'build_started_at' do
    it "returns correct time" do
      expect(event.build_started_at).to eq Time.utc(2016,3,20,9,46,55)
    end
  end

  describe 'build_finished_at' do
    it "returns correct time" do
      expect(event.build_finished_at).to eq Time.utc(2016,3,20,9,48,23)
    end
  end
end
