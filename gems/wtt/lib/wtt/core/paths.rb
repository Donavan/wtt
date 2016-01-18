require 'rake'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    class << self
      def rake_root
        @@root_dir ||= Rake.application.find_rakefile_location[1].freeze
      end

      def rake_root=(dir)
        @@root_dir = dir
      end

      def wtt_root
        "#{rake_root}/.wtt".freeze
      end
    end
  end
end
