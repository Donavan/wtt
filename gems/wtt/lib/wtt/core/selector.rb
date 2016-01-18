require 'wtt'
require 'rugged'
require 'set'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    # Select tests using Git information and a {Mapper}.
    class Selector
      attr_reader :tests
      attr_writer :walker, :mapping

      # @param opts [Hash] a hash with options
      def initialize(opts)
        @repo = opts[:repo]
        @metadata = opts[:meta_data]
        @walker = opts[:walker]
        @test_files = opts[:test_files]
        @mapping = opts[:mapping]
        @target_revision = @repo.lookup(opts[:target_sha]) if opts[:target_sha]
      end


      # Select tests using differences in anchored commit and target commit
      # (or current working tree) and {TestToCodeMapping}.
      #
      # @return [Set] a set of tests that might be affected by changes in base_sha...target_sha
      def select_tests!
        # Base should be the commit `anchor` has run on.
        # NOT the one test-to-code mapping was committed to.
        @base_obj = anchored_commit

        # select all tests if anchored commit does not exist
        return Set.new(@test_files) unless @base_obj

        change_count = 0
        
        @tests = Set.new
        diff.each_patch do |patch|
          change_count += 1
          file = patch.delta.old_file[:path]
          if test_file?(file)
            @tests << file
          else
            select_tests_from_patch(patch)
          end
        end
        @tests.delete(nil)
        puts "WTT found #{@tests.count} tests for #{change_count} changes."
        @tests
      end

      private

      def diff
        opts = {
            include_untracked: true,
            recurse_untracked_dirs: true
        }
        defined?(@target_revision) ? @base_obj.diff(@target_revision, opts) : @base_obj.diff_workdir(opts)
      end

      def mapping
        @mapping ||= begin
          sha = defined?(@target_revision) && !@target_revision.nil? ? @target_revision.oid : @repo.head.target_id
          Mapper.new(Storage.new(@repo, sha))
        end
      end

      # Select tests which are affected by the change of given patch.
      #
      # @param patch [Rugged::Patch]
      # @return [Set] set of selected tests
      def select_tests_from_patch(patch)
        target_lines = Set.new
        file = patch.delta.old_file[:path]


        patch.each_hunk do |hunk|
          target_lines.merge target_lines_from_hunk(hunk)
        end

        target_lines.each do |line|
          @tests += mapping.get_tests(file, line)
        end
      end

      # Find lines within a hunk
      #
      # @param hunk [Rugged::Hunk]
      # @return [Array] Lines that changed
      def target_lines_from_hunk(hunk)
        target_lines = []
        prev_line = nil
        hunk.each_line do |line|
          line_no = hunk_line_no(line, prev_line, hunk)
          target_lines << line_no unless line_no.nil?
          prev_line = line
        end
        target_lines
      end

      # Figure out the line number for a change
      #
      # @param line [Rugged::Line]
      # @param prev_line [Rugged::Line]
      # @param hunk [Rugged::Hunk]
      # @return [int] A line number or nil
      def hunk_line_no(line, prev_line, hunk)
        case line.line_origin
          when :addition
            if prev_line && !prev_line.addition?
              return prev_line.old_lineno
            elsif prev_line.nil?
              return hunk.old_start
            end
          when :deletion
            return line.old_lineno
        end

        nil
      end

      def walker
        @walker ||= Rugged::Walker.new(@repo)
      end

      # Find the commit `anchor` has been run on, or the previous commit.
      def anchored_commit
        return @repo.lookup(@metadata.anchored_commit) if @metadata.anchored_commit
        walker.sorting(Rugged::SORT_DATE)
        walker.push(@repo.head.target)
        commit = walker.find do |c|
          c.parents.size == 1
        end
        @repo.lookup(commit.oid)
      end

      # Check if the given file is a test file.
      #
      # @param file_from_mapping [String]
      def test_file?(file_from_mapping)
        @test_files.any? { |f| file_from_mapping.include?(f) }
      end
    end
  end
end
