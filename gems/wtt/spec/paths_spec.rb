RSpec.describe WTT::Core do

  describe 'rake_root' do
    it 'returns the directory the rakefile lives in by default' do
      WTT::Core.rake_root = nil
      expect(WTT::Core.rake_root.downcase).to end_with 'wtt/gems/wtt'
    end

    it 'returns the root dir for rake that was explicitly specified' do
      FAKE_ROOT = 'foo/bar'
      WTT::Core.rake_root = FAKE_ROOT
      expect(WTT::Core.rake_root.downcase).to eq FAKE_ROOT
    end
  end

  describe 'wtt_root' do
    it 'returns the path to store wtt data in' do
      WTT::Core.rake_root = nil
      expect(WTT::Core.wtt_root.downcase).to end_with 'wtt/gems/wtt/.wtt'
    end
  end

end