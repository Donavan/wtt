require 'simplecov'

class MockSCResult < SimpleCov::Result
  def initialize(original_result)
    @original_result = original_result.freeze
    @files = SimpleCov::FileList.new(original_result.map do |filename, coverage|
      MockSCSourceFile.new(filename, coverage)
    end.compact.sort_by(&:filename))
  end

end

class MockSCSourceFile < SimpleCov::SourceFile
  def initialize(filename, coverage)
    @filename = filename
    @coverage = coverage
    @src = ['','']
  end
end