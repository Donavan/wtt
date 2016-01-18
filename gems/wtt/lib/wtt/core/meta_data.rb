require 'wtt'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    # Bucket for holding data in the wtt file
    class MetaData
      STORAGE_SECTION = 'meta'

      # @param storage [Storage] Where to read//write
      def initialize(storage)
        @storage = storage
        read!
      end

      def anchored_commit
        @data['anchored_commit']
      end

      def anchored_commit=( val )
        @data['anchored_commit'] = val
      end

      def [](name)
        @data[name]
      end

      def []=(name, value)
        @data[name] = value
      end

      def read!
        @data = @storage.read(STORAGE_SECTION)
      end

      def write!
        @storage.write!(STORAGE_SECTION, @data)
      end
    end
  end
end
