require 'lita/buildkite_job_finished_event'
require 'json'

describe BuildkiteJobFinishedEvent do
  let(:json_path) { File.join(File.dirname(__FILE__), "fixtures", "buildkite_job_finished.json")}
  let(:json) { JSON.load(File.read(json_path)) }
  let(:event) { BuildkiteJobFinishedEvent.new(json)}

  describe '.name' do
    it "returns the correct value" do
      expect(event.name).to eq "job.finished"
    end
  end

  describe '.job_name' do
    it "returns the job name" do
      expect(event.job_name).to eq "Lint"
    end
  end

  describe '.job_state' do
    it "returns the job state" do
      expect(event.job_state).to eq "passed"
    end
  end

  describe '.job_started_at' do
    it "returns the correct time" do
      expect(event.job_started_at).to eq DateTime.new(2016,7,8,7,25,29)
    end
  end

  describe '.job_finished_at' do
    it "returns the correct time" do
      expect(event.job_finished_at).to eq DateTime.new(2016,7,8,7,25,40)
    end
  end

  describe '.agent_name' do
    it "returns the agent name" do
      expect(event.agent_name).to eq "tank-1"
    end
  end

  describe '.agent_hostname' do
    it "returns the agent hostname" do
      expect(event.agent_hostname).to eq "tank"
    end
  end

  describe '.build_branch' do
    it "returns the build branch name" do
      expect(event.build_branch).to eq "master"
    end
  end

  describe '.pipeline_name' do
    it "returns the pipeline name" do
      expect(event.pipeline_name).to eq "pipeline-name"
    end
  end
end
