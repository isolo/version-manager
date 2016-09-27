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
      version = versions.compact.sort.last
      file_content = vcs.show_file(branch_name(version), relative_path) if version
      version = ReleaseVersion.new(file_content) if file_content && ReleaseVersion.valid?(file_content)
      version
    end

    private

    attr_reader :filename, :filepath, :vcs

    def relative_path
      Pathname.new(full_path).relative_path_from(Pathname.new(ROOT_PATH)).to_s
    end

    def full_path
      File.expand_path(File.join(filepath, filename))
    end

    def branch_name(version)
      "release-#{version.short_version}"
    end
  end
end
