require "lita/days_since_master_failure_repository"

RSpec.describe DaysSinceMasterFailureRepository do
  let(:fake_redis) { instance_double(Redis) }
  let(:days_since_last_failure) { 123 }
  let(:last_reported_days) { 321 }

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

    it "yields days_since_last_failure, last_reported_days" do
      expect { |b|
        repository.record_result(nil, &b)
      }.to yield_with_args(instance_of(Integer), last_reported_days)
    end

    it "updates last-reported-days value" do
      repository.record_result(nil) {}

      expect(fake_redis).to have_received(:set).with("last-reported-days-my-pipeline", instance_of(Integer))
    end

    context "successful build" do
      it "does not update last-failure-at value" do
        success = true
        repository.record_result(success) {}

        expect(fake_redis).to_not have_received(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
      end
    end

    context "unsuccessful build" do
      it "updates last-failure-at value" do
        success = false
        repository.record_result(success) {}

        expect(fake_redis).to have_received(:set).with("last-failure-at-my-pipeline", instance_of(Integer))
      end
    end
  end
end
