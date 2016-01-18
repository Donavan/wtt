require 'wtt/core'
require 'drb/drb'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    # Helper class to gather coverage data via the Tracepoint API
    class Tracer
      def initialize
        @remotes = []
        reset_coverage
        connect_remotes WTT.configuration.remotes
      end

      def start_trace
        @debug = []
        reset_coverage
        start_remotes
        tracepoint.enable
      end

      def stop_trace
        stop_remotes
        tracepoint.disable
      end

      def coverage
        all_coverage = @coverage.dup
        @remotes.each { |r| merge_remote_coverage!(all_coverage, r.coverage) }
        all_coverage
      end

      private

      def merge_remote_coverage!(local, remote)
        remote.each do |filename, remote_coverage|
          if local.key?(filename)
            remote_coverage.each_with_index do |v, i|
              # We have to do this dance because the arrays contain nils
              current = local[filename][i].to_i
              local[filename][i] = current + v.to_i
            end
          else
            local[filename] = remote_coverage.dup
          end
        end
      end

      def start_remotes
        @remotes.each(&:start_trace)
      end

      def stop_remotes
        @remotes.each(&:stop_trace)
      end

      def reset_coverage
        @coverage = Hash.new { |h, k| h[k] = [] }
      end

      def should_include_file?(path)
        !WTT.configuration.reject_filters.any? { |f| f.match(path) }
      end

      def tracepoint
        @trace ||= TracePoint.new(:line, :call, :return) do |tp|
          if should_include_file?(tp.path)
            old_count = @coverage[tp.path][tp.lineno].to_i
            @coverage[tp.path][tp.lineno] = old_count + 1
          end
        end
      end

      def connect_remotes(remote_uris)
        remote_uris.each do |remote_uri|
          connect_remote remote_uri
        end
      end

      def connect_remote(remote_uri)
        service = DRbObject.new_with_uri(remote_uri)
        begin
          # Ask for the (empty) coverage to see if the service is live
          service.coverage
          @remotes << service
        rescue Exception => ex
          warn "Could not connect to Traced at #{remote_uri}.  #{ex.message}"
        end
      end
    end
  end
end
