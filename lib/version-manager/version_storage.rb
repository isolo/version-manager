module VersionManager
  class VersionStorage
    def initialize(vcs, storage_options)
      @filename = storage_options[:filename]
      @filepath = storage_options[:filepath]
      @vcs = vcs
    end

    def store(version)
      File.open(full_path, 'w') do |file|
        file << version
      end
      full_path
    end

    def latest_version
      versions = vcs.remote_branch_names.map do |name|
        ReleaseVersion.new(name) if ReleaseVersion.valid?(name)
      end
      versions.compact.sort.last
    end

    private

    attr_reader :filename, :filepath, :vcs

    def full_path
      File.expand_path(File.join(filepath, filename))
    end
  end
end
