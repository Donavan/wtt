require 'wtt'
require 'rugged'
require 'json'
require 'set'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    # Mapping from test file to executed code (i.e. coverage without execution count).
    #
    # Terminologies:
    #   spectra: { filename => [line, numbers, executed], ... }
    #   mapping: { test_file => spectra }
    class Mapper
      STORAGE_SECTION = 'mapping'.freeze

      attr_reader :mapping

      # @param storage [WTT::Core::Storage] The storage object to read and write from.
      def initialize(storage)
        @storage = storage
        read!
      end

      def matcher
        @matcher ||= WTT.configuration.matcher
      end

      # Append the new mapping to test-to-code mapping file.
      #
      # @param test [String] test file for which the coverage data is produced
      # @param coverage [Hash] coverage data generated using `Coverage.start` and `Coverage.result`
      # @return [void]
      def append_from_coverage(test, coverage)
        spectra = normalize_paths(select_project_files(spectra_from_coverage(coverage)))
        @mapping[test] = spectra
      end

      # Append the new mapping to test-to-code mapping file.
      #
      # @param test [String] test file for which the coverage data is produced
      # @param coverage [Hash] coverage data generated using `Coverage.start` and `Coverage.result`
      # @return [void]
      def append_from_simplecov(test, coverage)
        spectra = normalize_paths(select_project_files(spectra_from_simplecov(coverage)))
        @mapping[test] = spectra
      end

      # Read test-to-code mapping from storage.
      def read!
        @mapping = @storage.read(STORAGE_SECTION)
      end

      # Write test-to-code mapping to storage.
      def write!
        @storage.write!(STORAGE_SECTION, @mapping)
      end

      # Get tests affected from change of file `file` at line number `lineno`
      #
      # @param file [String] file name which might have effects on some tests
      # @param lineno [Integer] line number in the file which might have effects on some tests
      # @return [Set] a set of test files which might be affected by the change in file at lineno
      def get_tests(file, lineno)
        tests = Set.new
        @mapping.each do |test, spectra|
          lines = spectra[file]
          next unless lines
          tests << test if matcher.match(lines, lineno)
        end
        warn "No tests found for #{file}:#{lineno}." if file.end_with?( '.rb' )
        tests
      end

      def unmapped_tests
        @mapping.select { |_test, spectra| spectra.count == 0 }.keys
      end

      private

      # Convert absolute path to relative path from the project (Git repository) root.
      #
      # @param file [String] file name (absolute path)
      # @return [String] normalized file path
      def normalized_path(file)
        File.expand_path(file).sub("#{WTT::Core.rake_root}/", '')
      end

      # Normalize all file names in a spectra.
      #
      # @param spectra [Hash] spectra data
      # @return [Hash] spectra whose keys (file names) are normalized
      def normalize_paths(spectra)
        Hash[spectra.map { |k, v| [normalized_path(k), v] }]
      end

      # Filter out the files outside of the target project using file path.
      #
      # @param spectra [Hash] spectra data
      # @return [Hash] spectra with only files inside the target project
      def select_project_files(spectra)
        spectra.select do |filename, _lines|
          filename.start_with?(WTT::Core.rake_root)
        end
      end

      # Generate spectra data from Ruby coverage library's data
      #
      # @param cov [Hash] coverage data generated using `Coverage.result`
      # @return [Hash] spectra data
      def spectra_from_coverage(cov)
        spectra = Hash.new { |h, k| h[k] = [] }
        cov.each do |filename, executions|

          executions.each_with_index do |execution, i|
            next if execution.nil? || execution == 0
            spectra[filename] << i + 1
          end
        end
        spectra
      end

      # Generate spectra data from Ruby coverage library's data
      #
      # @param cov [Hash] coverage data generated using `Simplecov.result`
      # @return [Hash] spectra data
      def spectra_from_simplecov(cov)

        spectra = Hash.new { |h, k| h[k] = [] }
        cov.files.each do |file|
          filename = file.filename
          file.coverage.each_with_index do |execution, i|
            next if execution.nil? || execution == 0
            spectra[filename] << i + 1
          end
        end
        spectra
      end
    end
  end
end
