require "lita/days_since_master_failure_repository"
require "lita/buildkite_job_finished_event"

RSpec.describe DaysSinceMasterFailureRepository do
  let(:fake_redis) { instance_double(Redis) }
  let(:days_since_last_failure) { 2 }
  let(:last_reported_days) { 2 }
  let(:most_successful_days) { 0 }

  before do
    allow(fake_redis).to receive(:setnx).with("last-failure-at-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:setnx).with("most-successful-days-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:set).with("last-reported-days-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:set).with("most-successful-days-my-pipeline", instance_of(Integer))
    allow(fake_redis).to receive(:get).with("last-failure-at-my-pipeline").and_return(days_since_last_failure)
    allow(fake_redis).to receive(:get).with("last-reported-days-my-pipeline").and_return(last_reported_days)
    allow(fake_redis).to receive(:get).with("most-successful-days-my-pipeline").and_return(most_successful_days)
  end

  describe ".new" do
    it "initializes redis key/value pair if not set" do
      DaysSinceMasterFailureRepository.new(fake_redis, "my-pipeline")

      expect(fake_redis).to have_received(:setnx).with("last-failure-at-my-pipeline", instance_of(Integer)).ordered
      expect(fake_redis).to have_received(:setnx).with("most-successful-days-my-pipeline", instance_of(Integer)).ordered
    end
  end

  describe "#record_result" do
    let(:repository) { DaysSinceMasterFailureRepository.new(fake_redis, "my-pipeline") }

    it "yields a message" do
      expect { |b|
        repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: false, pipeline: "my-pipeline"), &b)
      }.to yield_with_args(instance_of(String))
    end

    context "successful build" do
      before do
        repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: true, pipeline: "my-pipeline")) {}
      end

      it "does not update last-failure-at value" do
        expect(fake_redis).to_not have_received(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
      end

      it "updates last-reported-days value" do
        expect(fake_redis).to have_received(:set).with("last-reported-days-my-pipeline", instance_of(Integer))
      end

      context "not a new record" do
        it "does not update most-successful-days value" do
          expect(fake_redis).to_not have_received(:set).with("most-successful-days-pipeline", instance_of(Integer))
        end
      end

      context "new record" do
        let(:last_reported_days) { 12 }
        let(:most_successful_days) { 9 }

        it "does not update most-successful-days value" do
          expect(fake_redis).to_not have_received(:set).with("most-successful-days-pipeline", instance_of(Integer))
        end
      end
    end

    context "unsuccessful build" do
      before do
        repository.record_result(instance_double(BuildkiteBuildFinishedEvent, passed?: false, pipeline: "my-pipeline")) {}
      end

      it "updates last-failure-at value" do
        expect(fake_redis).to have_received(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
      end

      it "updates last-reported-days value" do
        expect(fake_redis).to have_received(:set).with("last-reported-days-my-pipeline", instance_of(Integer))
      end

      context "not a new record" do
        it "does not update most-successful-days value" do
          expect(fake_redis).to_not have_received(:set).with("most-successful-days-pipeline", instance_of(Integer))
        end
      end

      context "new record" do
        let(:last_reported_days) { 12 }
        let(:most_successful_days) { 9 }

        it "updates most-successful-days value" do
          expect(fake_redis).to have_received(:set).with("most-successful-days-my-pipeline", instance_of(Integer))
        end
      end
    end
  end
end
