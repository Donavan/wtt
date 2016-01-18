RSpec.describe WTT do

  describe 'active protection' do
    it 'provides a helper function to set an env variable flag' do
      WTT.active=true
      expect(WTT.active?).to eq true
      expect(ENV[WTT::ENV_ACTIVE_FLAG]).to eq '1'

      WTT.active=false
      expect(WTT.active?).to eq false
      expect(ENV[WTT::ENV_ACTIVE_FLAG]).to be_nil
    end

    it 'provides a helper function to set an env variable flag for a block' do
      WTT.with_active_env do
        expect(WTT.active?).to eq true
        expect(ENV[WTT::ENV_ACTIVE_FLAG]).to eq '1'
      end
      WTT.active=false
      expect(WTT.active?).to eq false
      expect(ENV[WTT::ENV_ACTIVE_FLAG]).to be_nil
    end
  end


  describe 'reject filters' do
    it 'has default filters' do
      WTT.configure
      expect(WTT.configuration.reject_filters.count).to_not eq 0
    end

    it 'allows you to add filters' do
      WTT.configure do |config|
        config.use_default_filters = false
        config.add_reject_filter 'fake_filter'
      end
      expect(WTT.configuration.reject_filters.last).to eq 'fake_filter'
    end
  end

  describe 'remote coverage' do
    it 'can start/stop a coverage service' do
      WTT.configure do |config|
        config.traced_port = 4242
      end

      WTT.start_service
      expect(WTT.trace_service).to_not be_nil

      service = DRbObject.new_with_uri('druby://localhost:4242')

      expect{service.coverage}.to_not raise_error

      WTT.stop_service
      service = DRbObject.new_with_uri('druby://localhost:4242')
      expect{service.coverage}.to raise_error
    end

    it 'allows you to add filters' do
      WTT.configure do |config|
        config.add_reject_filter 'fake_filter'
      end
      expect(WTT.configuration.reject_filters.last).to eq 'fake_filter'
    end

    it 'allows you to add remove coverage services' do
      WTT.configure do |config|
        config.add_remote 'druby://fake_remote'
      end
      expect(WTT.configuration.remotes.last).to eq 'druby://fake_remote'
    end

    it 'adds the protocol prefix to remotes if missing' do
      WTT.configure do |config|
        config.add_remote 'fake_remote'
      end
      expect(WTT.configuration.remotes.last).to eq 'druby://fake_remote'
    end
  end

end