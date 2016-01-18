require 'wtt/core'
require 'rake'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    # Helper to declare take tasks for anchor raise/drop.
    class AnchorTasks
      include Rake::DSL
      def initialize
        define_anchor_tasks
      end

      def define_anchor_tasks
        namespace :wtt do
          desc 'Set the SHA for use in WTT'
          task 'anchor_drop' do
            WTT::Core.anchor_drop
          end

          desc 'Clear the SHA for use in WTT'
          task 'anchor_raise' do
            WTT::Core.anchor_raise
          end
        end
      end
    end
  end
end
