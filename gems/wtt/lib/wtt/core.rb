require 'wtt/core/version'
require 'wtt/core/paths'
require 'wtt/core/storage'
require 'wtt/core/mapper'
require 'wtt/core/selector'
require 'wtt/core/meta_data'
require 'wtt/core/tracer'
require 'wtt/core/trace_service'
require 'wtt/core/anchor_task'
require 'wtt/core/matchers'
require 'rugged'


# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    def self.create_core_tasks
        AnchorTasks.new
    end

    def self.anchor_drop(sha = nil)
      begin
        repo = Rugged::Repository.discover('.')
        sha ||= repo.head.target_id

        storage = WTT::Core::Storage.new repo

        meta = WTT::Core::MetaData.new(storage)
        meta.anchored_commit = sha
        meta.write!
        puts "WTT now anchored to #{sha}"
      rescue Exception => ex
        puts "Exception thrown while dropping anchor: #{ex.message}"
      end
    end


    def self.anchor_raise
      begin
        repo = Rugged::Repository.discover('.')
        storage = WTT::Core::Storage.new repo

        meta = WTT::Core::MetaData.new(storage)
        meta.anchored_commit = nil
        meta.write!
        puts 'WTT now unanchored'
      rescue Exception => ex
        puts "Exception thrown while raising anchor: #{ex.message}"
      end
    end

    private


  end
end