
def fixture_path
  File.expand_path('./fixtures', File.dirname(__FILE__))
end

def save_fixture(id, data)
  filename = "#{fixture_path}/#{id}.yaml"
  File.open( filename, 'w' ) do |out|
    YAML.dump( data, out )
  end
end

def load_fixture(id)
  filename = "#{fixture_path}/#{id}.yaml"
  YAML.load_file filename
end

def save_cover(id, data)
  save_fixture( "coverage_#{id}", data )
end

def load_cover(id)
  load_fixture( "coverage_#{id}" )
end
