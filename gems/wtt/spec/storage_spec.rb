
RSpec.describe WTT::Core do

  describe WTT::Core::Storage do
    context 'without a ref SHA' do
      after(:each) do
        #binding.pry;2
      end

      before(:all) do
        WTT::Core.rake_root = File.expand_path('./fixtures', File.dirname(__FILE__))
        @storage = WTT::Core::Storage.new
        @test_hash = { 'test_value' => 'this is a test' }
      end

      it 'reads data from the current file' do
        section = @storage.read 'test_section'
        expect(section['test_value']).to_not be_nil
      end

      it 'writes data to the current file' do
        @storage.write! 'test_section', @test_hash
        section = @storage.read 'test_section'
        expect(section['test_value']).to eq 'this is a test'
      end

    end

    context 'with a ref SHA' do
      before(:all) do
        WTT::Core.rake_root = File.expand_path('./fixtures', File.dirname(__FILE__))
        sha = '31484a592fdfc91516b74ea93f18e6fc2251accb'
        repo = Rugged::Repository.discover('.')
#        binding.pry;2
        @storage = WTT::Core::Storage.new repo, sha
        @test_hash = { 'test_value' => 'this is a test' }
      end

      it 'reads data from the historical file' do
        skip 'Skipping this until it is all mocked'
        current_storage = WTT::Core::Storage.new
        current_storage.write! 'test_section', @test_hash

        section = @storage.read 'test_section'
        expect(section['test_value']).to eq('this was a test')
      end

      it 'refuses to write to a historical file' do
        expect{ @storage.write!('test_section', @test_hash) }.to raise_error('Data cannot be written back in git history')
      end

    end


  end

end