# What to Test
Stop running tests which are clearly not affected by the change you introduced in your commit!

This project started as a fork of [Test This, Not That!](https://github.com/Genki-S/ttnt) A Google Summer of Code 2015 project under Ruby on Rails. Where TTNT is specific to the Minitest framework, WTT is easily extensible to support other frameworks.


## Usage
### The basics
Add the gems to your gemfile.

```ruby
gem 'wtt-core'
gem 'wtt-rspec'
```

Add the tasks to your Rakefile, they accept the same arguements as the normal RSpec tasks.

```ruby
require 'wtt/rspec'

WTT::Core.create_core_tasks  # Define the anchor_raise/drop tasks
namespace :wtt do
	desc 'Produce a map by running all RSpec tests for the gem'
	WTT::RSpec::MapTask.new(:map_specs, :command_options) do |t, args|
	  t.rspec_opts = '-t ~wip -t ~off --color '
	  t.rspec_opts << args[:command_options] if args[:command_options]
	end
	
	desc 'Run only specs likely to break.'
	WTT::RSpec::SpecTask.new(:specs, :command_options) do |t, args|
	  t.rspec_opts = '-t ~wip -t ~off --color '
	  t.rspec_opts << args[:command_options] if args[:command_options]
	end
end
```


Map your code with:
```
bundle exec rake wtt:map_specs
```

Run tests:
```
bundle exec rake wtt:specs
```
### Determining if WTT is actively mapping
You can call *WTT.active?* or check if *ENV['WTT_ACTIVE']* is non-null.

### Anchoring
WTT uses git to determine which files you've changed so that it knows which tests to run.  Without an anchor, it will use HEAD. When an anchor is dropped WTT will consider each since the anchor revsion.  

Dropping an anchor at the start of feature work allows you an extra measure of confidence that you're running the correct tests.

Drop an anchor with:
```
bundle exec rake wtt:anchor_drop
```

And raise it with:
```
bundle exec rake wtt:anchor_raise
```


### Configuration
WTT exposes a configuration property that can be accessed like so:

```ruby
require 'wtt'

WTT.configure do |config|
  # Do stuff with config
end
```

The configuration object exposes the following methods:

| Method                          | Description                                                                                                                                                        |
|---------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| add_reject_filter(filter_regex) | Add a regex to exclude files from the coverage.  The default filters exclude anything that has /lib/ruby/ or /spec/ in the path. |
| add_remote(uri)                 | Add a remote trace service (see below).  URI should be in the format of 'HOSTNAME:PORT'                                                                            |
| matcher=                        | Which matcher to use (see below).                                                                                                                                  |
| traced_port=                    | The port number to be used when starting a trace service.,(see below)                                                                                              |

There are currently three matchers that can be used to select your tests.  It's not currently known which is the best to use so the most inclusive (Touch) is used as the default.

**Touch**: Will match a test if the line that was changed lies between the first and last line the test hit in the file.

```ruby
WTT.configure do |config|
  config.matcher = WTT.touch_matcher
end
```

**Exact**: Will match a test if the exact line that was changed was touched by the test.

```ruby
WTT.configure do |config|
  config.matcher = WTT.exact_matcher
end
```

**Fuzzy**: Will match a test if the line that was changed is within a specified number of lines (Default 11).

```ruby
WTT.configure do |config|
  num_lines = 5	
  config.matcher = WTT.fuzzy_matcher(num_lines)
end
```


### Including coverage from the system under test
WTT includes support for capturing coverage from external processes and mapping it to tests.

Configure WTT on the server side (in boot.rb for example):

```ruby
require 'wtt'

WTT.configure do |config|
  config.traced_port = 4242 # Any unique port will do
end

WTT.start_service unless Rails.env.production?
```

Configure WTT on the client side with the address/port of your remote (in spec_helper.rb for example)

```ruby
require 'wtt'

WTT.configure do |config|
  config.add_remote 'localhost:4242'
end
```

Multiple remotes can be added by calling add_remote again and passing a different host/port.




## How it works
### Mappping
First the WTT "Map Task" runs each test and gathers code coverage for individual test scenarios using the Tracepoint API in Ruby 2.x.  Data from any remotes is merged with the local coverage data to produce a map. 

After the map has been generated the WTT can use it to determine which tests to run. 

### Executing
The WTT spec task will interrogate your repo to determine which source files have changed.  Using the patchset, it will select tests which cover the files (and lines within the files) that have changed.  If a test has been modified it will likewise be slected to be run.


