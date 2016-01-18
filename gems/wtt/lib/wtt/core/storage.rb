require 'rugged'

module WTT
  module Core
    # A utility class to store WTT data such as test-to-code mapping and metadata.
    class Storage
      # Initialize the storage from given repo and sha. This reads contents from
      # a `.wtt` file. When sha is not nil, contents of the file on that commit
      # is read. Data can be written only when sha is nil (written to current
      # working tree).
      #
      # @param repo [Rugged::Repository]
      # @param sha [String] sha of the commit which data should be read from.
      #   nil means reading from/writing to current working tree.
      def initialize(repo = nil, sha = nil)
        @repo = repo
        @sha = sha
      end

      # Read data from the storage in the given section.
      #
      # @param section [String]
      # @return [Hash]
      def read(section)
        data_from_str(read_storage_content)[section] || {}
      end

      # Write value to the given section in the storage.
      # Locks the file so that concurrent write does not occur.
      #
      # @param section [String]
      # @param value [Hash]
      # rubocop:disable Metrics/AbcSize
      def write!(section, value)
        fail 'Data cannot be written to the storage back in git history' unless @sha.nil?
        File.open(WTT::Core.wtt_root, File::RDWR | File::CREAT, 0644) do |f|
          f.flock(File::LOCK_EX)
          data = data_from_str( f.read )
          data[section] = value
          f.rewind
          f.write(data.to_json)
          f.flush
          f.truncate(f.pos)
        end
      end
      # rubocop:enable Metrics/AbcSize

      private

      def data_from_str(str)
        str.length > 0 ? JSON.parse(str) : {}
      end

      def filename_from_repository_root
        WTT::Core.wtt_root.gsub(@repo.workdir, '')
      end

      def storage_file_oid
        paths = filename_from_repository_root.split(File::SEPARATOR)
        obj = find_file_in_repo paths
        return nil unless obj
        obj[:oid]
      end

      def find_file_in_repo(paths)
        tree = @repo.lookup(@sha).tree
        dirs = paths[0...-1]
        filename = paths[-1]

        dirs.each do |dir|
          obj = tree[dir]
          return nil unless obj
          tree = @repo.lookup(obj[:oid])
        end
        tree[filename]
      end


      def read_storage_content
        if @sha
          oid = storage_file_oid
          oid.nil? ? '' : @repo.lookup(oid).content
        else
          File.exist?(WTT::Core.wtt_root) ? File.read(WTT::Core.wtt_root) : ''
        end
      end
    end
  end
end
