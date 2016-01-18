require 'rspec/core'
RSpec::Support.require_rspec_core 'formatters/base_formatter'
require 'wtt'
require 'rugged'


# Top level namespace for What to Test
module WTT
  # Functionality related to rspec
  module RSpec
    # Rspec formatter that gathers coverage information for each scenario.
    class Formatter < ::RSpec::Core::Formatters::BaseFormatter
      ::RSpec::Core::Formatters.register self, :example_passed, :example_failed, :close, :start

      def initialize(output)
        super
        @tests = []
        @repo = Rugged::Repository.discover(Dir.pwd)
        @storage = WTT::Core::Storage.new @repo
        @mapping = WTT::Core::Mapper.new(@storage)
        @tracer = WTT::Core::Tracer.new
      end


      def start(_notification)
        @tracer.start_trace
      end

      def example_passed(notification)
        record_example notification.example
      end

      def example_failed(notification)
        record_example notification.example
      end

      def record_example(example)
        @tracer.stop_trace
        @mapping.append_from_coverage("RSPEC:#{example.id}", @tracer.coverage)
        @tracer.start_trace
      end

      def close(_example)
        @tracer.stop_trace
        @mapping.write!
      end
    end
  end
end
