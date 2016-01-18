require 'rspec/core'
RSpec::Support.require_rspec_core 'formatters/base_formatter'
require 'wtt'
require 'rugged'
require 'wtt/core'

RSpec.configure do |config|
  config.before(:each) do
    fail('Fail each test immediately' ) if ENV['WTT_INDEXING'] == '1'
  end
end

# Top level namespace for What to Test
module WTT
  # Functionality related to rspec
  module RSpec
    # @private
    class Indexer < ::RSpec::Core::Formatters::BaseFormatter
      ::RSpec::Core::Formatters.register self, :example_passed, :example_failed, :close
      def initialize(output)
        super
        @tests = []
        ENV['WTT_INDEXING'] ||= '1'
        @repo = Rugged::Repository.discover(Dir.pwd)
        @storage = WTT::Core::Storage.new(@repo)
        @mapping = WTT::Core::Mapper.new(@storage)
      end

      def example_passed(notification)
        record_example notification.example
      end

      def example_failed(notification)
        record_example notification.example
      end

      def record_example(example)
        @tests << example.id
      end

      def close(_example)
        meta = WTT::Core::MetaData.new(@storage)
        meta['specs'] = @tests
        meta.write!
      end
    end
  end
end
