require 'wtt/core'
require 'drb/drb'

# Top level namespace for What to Test
module WTT
  ENV_ACTIVE_FLAG = 'WTT_ACTIVE'.freeze
  class << self
    attr_accessor :trace_service, :config
  end

  def self.with_active_env
    self.active = true
    yield
    self.active = false
  end

  def self.active=(val)
    ENV[ENV_ACTIVE_FLAG] = '1' if val
    ENV.delete ENV_ACTIVE_FLAG unless val
  end

  def self.active?
    ENV[ENV_ACTIVE_FLAG] != nil
  end

  def self.configuration
    self.config ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
    self.configuration.matcher ||= touch_matcher
    self.configuration.default_reject_filters if self.configuration.use_default_filters
  end

  def self.start_service
    port = self.configuration.traced_port
    if port > 0 && self.trace_service.nil?
      uri = "druby://localhost:#{port}"
      self.trace_service = DRb.start_service(uri, Core::TraceService.new)
    end
    self.trace_service
  end

  def self.stop_service
    unless self.trace_service.nil?
      DRb.remove_server(self.trace_service)
      DRb.stop_service
      self.trace_service = nil
    end

  end

  def self.exact_matcher
    Core::Matchers::Exact.new
  end

  def self.touch_matcher
    Core::Matchers::Touch.new
  end

  def self.fuzzy_matcher(spread = 11)
    Core::Matchers::Fuzzy.new(spread)
  end

  class Configuration
    attr_accessor :traced_port
    attr_accessor :reject_filters
    attr_accessor :use_default_filters
    attr_accessor :remotes
    attr_accessor :matcher

    def initialize
      @traced_port = 0
      @remotes = []
      @reject_filters = []
      @use_default_filters = true
    end

    def add_reject_filter(filter)
      @reject_filters << filter
    end

    def add_remote(uri)
      uri = "druby://#{uri}" unless uri.start_with?('druby://')
      @remotes << uri
    end


    def default_reject_filters
      @reject_filters.concat( [ /_spec.rb$/,      # Reject spec files,
                          /spec\//,       # Reject anything in the spec folder or below
                          /\/lib\/ruby\/|\/gems\/gems\/|usr\/share\/ruby\//   # Reject any Ruby gem/libraries
       ])
    end
  end
end