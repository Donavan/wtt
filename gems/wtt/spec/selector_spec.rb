require 'mocks/repo_mocks'

RSpec.describe WTT::Core do
  before(:all) do
    WTT.configure
  end

  describe WTT::Core::Selector do
    def mock_repo(target = nil)
      repo = instance_double('Rugged::Repo')

      allow(repo).to receive(:head) { MockHead.new 'abc' }
      allow(repo).to receive(:workdir) { '/code/wtt/' }
      allow(repo).to receive(:lookup) { target } unless target.nil?

      repo
    end


    def mock_diff(patchset)
      MockDiff.new( load_fixture( patchset ) )
    end

    def mock_target(patchset)
      mock_target = instance_double('Rugged::Repo')
      allow(mock_target).to receive(:diff_workdir) { mock_diff(patchset) }
      mock_target
    end

    def mock_storage(fixture_file)
     storage = instance_double( 'WTT::Core::Storage' )
     allow(storage).to receive(:read) { load_fixture(fixture_file)['mapping'] }
     allow(storage).to receive(:write!)
     storage
    end


    context 'with an anchored commit' do
      def anchored_opts(patchset, test_files)
        mock_target = mock_target(patchset)
        repo = mock_repo(mock_target)

        walker = instance_double('Rugged::Walker')
        meta = instance_double( 'WTT::Core::MetaData' )

        opts = {
            meta_data: meta,
            repo: repo,
            walker: walker,
            test_files: test_files,
            mapping: WTT::Core::Mapper.new( mock_storage( 'mapping_1' ) )
        }
        allow(meta).to receive(:anchored_commit) { 'some_sha' }
        allow(repo).to receive(:lookup) { mock_target }
        opts
      end


      it 'selects tests for files that changed' do
        selector = WTT::Core::Selector.new anchored_opts('patchset_1', [])
        tests = selector.select_tests!
        expect(tests).to include('some_test_id')
        expect(tests).to include('another_test_id')
      end

      it 'includes any test that changed when selecting tests' do
        selector = WTT::Core::Selector.new anchored_opts('patchset_1', ['spec/test_spec'])
        tests = selector.select_tests!
        expect(tests).to include('spec/test_spec')
      end
    end

    context 'without an anchored commit' do
      def unanchored_opts(patchset, test_files)
        mock_target = mock_target(patchset)
        repo = mock_repo(mock_target)

        walker = instance_double('Rugged::Walker')
        allow(walker).to receive(:sorting)
        allow(walker).to receive(:push)
        allow(walker).to receive(:find) { MockCommit.new }

        meta = instance_double( 'WTT::Core::MetaData' )

        opts = {
            meta_data: meta,
            repo: repo,
            walker: walker,
            test_files: test_files,
            mapping: WTT::Core::Mapper.new( mock_storage( 'mapping_1' ) )
        }
        allow(meta).to receive(:anchored_commit) { nil }
        allow(repo).to receive(:lookup) { mock_target }
        opts
      end


      it 'selects tests for files that changed' do
        selector = WTT::Core::Selector.new unanchored_opts('patchset_2', [])
        tests = selector.select_tests!
        expect(tests).to include('some_test_id')
        expect(tests).to_not include('spec/test_spec2')
      end

      it 'includes any test that changed when selecting tests' do
        selector = WTT::Core::Selector.new unanchored_opts('patchset_2', ['spec/test_spec2'])
        tests = selector.select_tests!
        expect(tests).to include('spec/test_spec2')
      end
    end
  end

end