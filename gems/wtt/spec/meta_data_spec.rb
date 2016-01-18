RSpec.describe WTT::Core do
  describe WTT::Core::MetaData do

    before(:each) do
      @storage = instance_double( 'WTT::Core::Storage' )
      allow(@storage).to receive(:write!)
      allow(@storage).to receive(:read) { load_fixture('mapping_1')['meta'] }
    end

    it 'reads from storage when cretaed' do
      expect(@storage).to receive(:read)
      WTT::Core::MetaData.new(@storage)
    end

    it 'writes from storage when asked' do
      expect(@storage).to receive(:read)
      meta = WTT::Core::MetaData.new(@storage)
      meta.write!
    end

    it 'provides the anchored commit' do
      meta = WTT::Core::MetaData.new(@storage)
      expect(meta.anchored_commit).to eq('some_sha')
    end

    it 'sets the anchored commit' do
      meta = WTT::Core::MetaData.new(@storage)
      meta.anchored_commit = 'another_sha'
      expect(meta.anchored_commit).to eq('another_sha')
    end

    it 'stores arbitrary data' do
      meta = WTT::Core::MetaData.new(@storage)
      meta[:foo] = :bar
      expect(meta[:foo]).to eq(:bar)
    end

  end
end