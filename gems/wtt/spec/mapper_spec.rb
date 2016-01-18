require 'mocks/mock_sc_result'

RSpec.describe WTT::Core do
  describe WTT::Core::Mapper do


    context 'reading and writing' do
      before(:all) do
        WTT.configure
        WTT::Core.rake_root = '/code/wtt/gems/wtt'
        @mapping_key = WTT::Core::Mapper::STORAGE_SECTION
      end
      before(:each) do
        @storage = instance_double( 'WTT::Core::Storage' )
        allow(@storage).to receive(:write!)
      end

      it 'reads the mapping data when created' do
        allow(@storage).to receive(:read) { Hash.new }
        expect(@storage).to receive(:read)
        WTT::Core::Mapper.new @storage
      end

      it 'preserves existing data in the storage' do
        allow(@storage).to receive(:read) { load_fixture('mapping_1')['mapping'] }
        expect(@storage).to receive(:write!) do |section, data|
          expect(section).to eq @mapping_key
          expect(data['some_test_id'].class).to eq Hash
          expect(data['some_test_id']['lib/file1.rb']).to_not be_nil
        end
        mapper = WTT::Core::Mapper.new @storage
        mapper.write!
      end

      it 'appends coverage data to the storage for files in the project' do
        allow(@storage).to receive(:read) { Hash.new }

        expect(@storage).to receive(:write!) do |_section, data|
          expect(data['unit_test_1'].class).to eq Hash
          expect(data['unit_test_1']['lib/file1.rb']).to_not be_nil
          expect(data['unit_test_1']['lib/file1.rb'].class).to eq Array
        end
        mapper = WTT::Core::Mapper.new @storage
        mapper.append_from_coverage 'unit_test_1', load_cover(1)
        mapper.write!
      end

      it 'appends coverage data from SimpleCov to the storage for files in the project' do
        allow(@storage).to receive(:read) { Hash.new }

        expect(@storage).to receive(:write!) do |_section, data|
          expect(data['unit_test_1'].class).to eq Hash
          expect(data['unit_test_1']['lib/file1.rb']).to_not be_nil
          expect(data['unit_test_1']['lib/file1.rb'].class).to eq Array
        end
        mapper = WTT::Core::Mapper.new @storage

        result = MockSCResult.new(load_cover(1))

        mapper.append_from_simplecov 'unit_test_1', result
        mapper.write!
      end
    end

    context 'test queries' do
      context 'with touch matcher' do
        before(:each) do

          WTT.configure do |config|
            config.matcher = WTT.touch_matcher
          end
          WTT::Core.rake_root = '/code/wtt/gems/wtt'
          @mapping_key = WTT::Core::Mapper::STORAGE_SECTION

          @storage = instance_double( 'WTT::Core::Storage' )
          allow(@storage).to receive(:write!)
          allow(@storage).to receive(:read) { load_fixture('mapping_1')['mapping'] }
        end

        it 'can select tests based on source file and line number' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 1
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(2)
        end

        it 'excludes tests based on line number' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 32
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(1)
        end

        it 'returns all test that touch the file if the line number is zero' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 0
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(3)
        end

        it 'returns and empty set when no tests match the file' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'nonexisting_file.rb', 1
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(0)
        end

        it 'returns and empty set when no tests match the line' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 99
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(0)
        end
      end
      context 'with exact matcher' do
        before(:each) do

          WTT.configure do |config|
            config.matcher = WTT.exact_matcher
          end
          WTT::Core.rake_root = '/code/wtt/gems/wtt'
          @mapping_key = WTT::Core::Mapper::STORAGE_SECTION

          @storage = instance_double( 'WTT::Core::Storage' )
          allow(@storage).to receive(:write!)
          allow(@storage).to receive(:read) { load_fixture('mapping_1')['mapping'] }
        end

        it 'can select tests based on source file and line number' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 2
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(2)
        end

        it 'excludes tests based on line number' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file3.rb', 13
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(1)
        end

        it 'returns all test that touch the file if the line number is zero' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 0
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(3)
        end

        it 'returns and empty set when no tests match the file' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'nonexisting_file.rb', 1
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(0)
        end

        it 'returns and empty set when no tests match the line' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 99
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(0)
        end
      end

      context 'with fuzzy matcher' do
        before(:each) do

          WTT.configure do |config|
            config.matcher = WTT.fuzzy_matcher
          end
          WTT::Core.rake_root = '/code/wtt/gems/wtt'
          @mapping_key = WTT::Core::Mapper::STORAGE_SECTION

          @storage = instance_double( 'WTT::Core::Storage' )
          allow(@storage).to receive(:write!)
          allow(@storage).to receive(:read) { load_fixture('mapping_1')['mapping'] }
        end

        it 'can select tests based on source file and line number' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 2
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(2)
        end

        it 'excludes tests based on line number' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 23
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(1)
        end

        it 'returns all test that touch the file if the line number is zero' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 0
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(3)
        end

        it 'returns and empty set when no tests match the file' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'nonexisting_file.rb', 1
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(0)
        end

        it 'returns and empty set when no tests match the line' do
          mapper = WTT::Core::Mapper.new @storage
          selected_tests = mapper.get_tests 'lib/file1.rb', 99
          expect(selected_tests).to_not be_nil
          expect(selected_tests.count).to eq(0)
        end
      end
    end
  end
end