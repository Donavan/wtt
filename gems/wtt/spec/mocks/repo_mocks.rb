# Mock objects for faking git repo objects
MockHead = Struct.new(:target)

# A single commit
class MockCommit
  attr_accessor :oid, :parents
  def initialize
    @oid = 'foo'
    @parents = ['bar']
  end
end

# A line in a hunk
class MockHunkLine
  attr_accessor :line_origin, :old_lineno, :old_start, :addition

  def addition?
    @addition == true
  end

  def initialize(lineo, oldl, olds, add)
    @line_origin = lineo
    @old_lineno = oldl
    @old_start = olds
    @addition = add
  end
end

# A hunk in a patch
class MockHunk
  attr_accessor :old_start
  def initialize(lines, olds)
    @lines = lines.nil? ? [] : lines.dup
    @old_start = olds || 2
  end

  def each_line
    @lines.each do |line|
      yield line
    end
  end
end

# Mock delta of a file
class MockDelta
  def initialize(file)
    @filename = file
  end

  def old_file
    { path: @filename }
  end
end

# Mock patch in a diff
class MockPatch
  attr_reader :delta

  def initialize(filename, hunks)
    @hunks = hunks
    @delta = MockDelta.new(filename)
  end

  def each_hunk
    @hunks.each do |hunk|
      yield hunk
    end
  end
end

# A mock diff ofa repo
class MockDiff
  def initialize(patches)
    @patches = patches
  end

  def each_patch
    @patches.each do |patch|
      yield patch
    end
  end
end