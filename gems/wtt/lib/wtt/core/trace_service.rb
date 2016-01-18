
# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    # Service for gathering coverage information and sending it back via DRB.
    class TraceService
      attr_reader :coverage

      def initialize
        @coverage = Hash.new { |h, k| h[k] = [] }
        @trace = TracePoint.new(:line) do |tp|
          if should_include_file?( tp.path )
            old_count = @coverage[tp.path][tp.lineno].to_i
            @coverage[tp.path][tp.lineno] = old_count + 1
          end
        end
      end

      def start_trace
        reset_coverage
        @trace.enable
      end

      def stop_trace
        @trace.disable
      end

      def coverage
        stop_trace
        results = @coverage.dup
        start_trace
        return results
      end

      private

      def reset_coverage
        @coverage = Hash.new { |h, k| h[k] = [] }
      end

      def should_include_file?(path)
        !WTT.configuration.reject_filters.any? {|f| f.match(path)}
      end
    end
  end
end