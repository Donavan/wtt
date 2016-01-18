require 'wtt/rspec'
require 'rake'
require 'rake/tasklib'
require 'rspec/support'
require 'rspec/core/rake_task'


# Top level namespace for What to Test
module WTT
  # Functionality related to rspec
  module RSpec
    # Task that runs all specs and produces a map.
    class SpecTask < ::RSpec::Core::RakeTask
      MAP_FORMATTER = '--require wtt/rspec/formatter --format WTT::RSpec::Formatter --format progress'.freeze
      alias_method :orig_rspec_opts, :rspec_opts
      alias_method :orig_run_task, :run_task

      def rspec_opts
        "#{MAP_FORMATTER} #{orig_rspec_opts}"
      end

      def run_task(verbose)
        WTT.with_active_env { orig_run_task verbose }
      end

      def file_inclusion_specification
        repo = Rugged::Repository.discover(Dir.pwd)
        storage = WTT::Core::Storage.new( repo )
        meta = WTT::Core::MetaData.new( storage )

        opts = {
            meta_data: meta,
            repo: repo,
            test_files: FileList[pattern].sort.map { |file| escape( file ) },
            mapping: WTT::Core::Mapper.new( storage )
        }

        selector = WTT::Core::Selector.new opts
        tests = selector.select_tests!
        tests.to_a.select { |t| t.start_with? 'RSPEC:' }.map { |t| t.gsub(/RSPEC:/, '') }
      end
    end
  end
end
