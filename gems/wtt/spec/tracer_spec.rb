RSpec.describe WTT::Core::Tracer do

  describe 'local_coverage' do

    before(:each) do
      @tracer = WTT::Core::Tracer.new
    end

    def dummy_fn
      ''
    end

    it 'gathers code coverage from the local process' do
      @tracer.start_trace
      WTT.active?
      @tracer.stop_trace

      expect(@tracer.coverage.count).to eq 2
    end

    it 'ignores coverage for files in the exclusion filter' do
      WTT.configure do |config|
        config.add_reject_filter /tracer/
      end
      @tracer.start_trace
      WTT.active?
      @tracer.stop_trace

      expect(@tracer.coverage.count).to eq 1
    end
  end

  describe 'remote_coverage' do

    before(:all) do

      WTT.configure do |config|
        config.traced_port = 4242
        config.add_remote 'localhost:4242'
      end

      @service = WTT.start_service
      @tracer = WTT::Core::Tracer.new
    end

    def dummy_remote_fn
      ''
    end

    it 'gathers code coverage from the remote process' do
      @tracer.start_trace
      WTT.active?
      @tracer.stop_trace
      expect(@tracer.coverage.count).to eq 2
    end

    it 'ignores coverage for remote files in the exclusion filter' do
      WTT.configure do |config|
        config.add_reject_filter /wtt/
      end
      @tracer.start_trace
      WTT.active?
      @tracer.stop_trace

      expect(@tracer.coverage.count).to eq 0
    end
  end
end