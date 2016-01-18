require 'rake'
require 'rake/tasklib'
require 'rspec/support'
require 'rspec/core/rake_task'

# Top level namespace for What to Test
module WTT
  # Functionality related to rspec
  module RSpec
    # Task that runs all specs and produces a map.
    class MapTask < ::RSpec::Core::RakeTask
      MAP_FORMATTER = '--require wtt/rspec/formatter --format WTT::RSpec::Formatter --format progress'.freeze

      def format_opts(formatter)
        "#{formatter} #{rspec_opts} --no-fail-fast"
      end

      def map_command
        cmd_parts = []
        cmd_parts << RUBY
        cmd_parts << ruby_opts
        cmd_parts << rspec_load_path
        cmd_parts << escape(rspec_path)
        cmd_parts << file_exclusion_specification
        cmd_parts << file_inclusion_specification
        cmd_parts << format_opts( MAP_FORMATTER )
        cmd_parts.flatten.reject(&blank).join(" ")
      end

      def run_task(verbose)
        WTT.with_active_env do
          @repo = Rugged::Repository.discover(Dir.pwd)
          @storage = WTT::Core::Storage.new @repo

          puts 'Mapping RSpec tests...'

          command = "#{map_command}"
          puts command if verbose
          system(command)
        end
      end
    end
  end
end
