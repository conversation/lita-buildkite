require "lita/days_since_master_failure_repository"
require "lita/buildkite_job_finished_event"

RSpec.describe DaysSinceMasterFailureRepository do
  let(:fake_redis) { instance_double(Redis) }
  let(:days_since_last_failure) { 2 }
  let(:last_reported_days) { 2 }

  before do
    allow(fake_redis).to receive(:setnx).with("last-failure-at-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:set).with("last-reported-days-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:get).with("last-failure-at-my-pipeline").and_return(days_since_last_failure)
    allow(fake_redis).to receive(:get).with("last-reported-days-my-pipeline").and_return(last_reported_days)
  end

  describe ".new" do
    it "initializes redis key/value pair if not set" do
      DaysSinceMasterFailureRepository.new(fake_redis, "my-pipeline")

      expect(fake_redis).to have_received(:setnx).with("last-failure-at-my-pipeline", instance_of(Integer)).ordered
    end
  end

  describe "#record_result" do
    let(:repository) { DaysSinceMasterFailureRepository.new(fake_redis, "my-pipeline") }

    it "yields a message" do
      expect { |b|
        repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: false, pipeline: "my-pipeline"), &b)
      }.to yield_with_args(instance_of(String))
    end

    it "updates last-reported-days value" do
      repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: false, pipeline: "my-pipeline")) {}

      expect(fake_redis).to have_received(:set).with("last-reported-days-my-pipeline", instance_of(Integer))
    end

    context "successful build" do
      it "does not update last-failure-at value" do
        repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: true, pipeline: "my-pipeline")) {}

        expect(fake_redis).to_not have_received(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
      end
    end

    context "unsuccessful build" do
      it "updates last-failure-at value" do
        repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: false, pipeline: "my-pipeline")) {}

        expect(fake_redis).to have_received(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
      end
    end
  end
end
