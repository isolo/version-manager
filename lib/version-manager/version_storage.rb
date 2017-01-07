module VersionManager
  class VersionStorage
    class WrongLatestVersionError < StandardError
      attr_reader :version
      def initialize(version)
        @version = version
      end
    end

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
        name = name.split('/').last
        ReleaseVersion.new(name) if name.include?('release-') && ReleaseVersion.valid?(name)
      end
      version = select_appropriate_versions(versions).last
      file_content = vcs.show_file(version.branch, relative_path) if version
      version = ReleaseVersion.new(file_content) if file_content && ReleaseVersion.valid?(file_content)
      version
    end

    private

    attr_reader :filename, :filepath, :vcs

    def relative_path
      Pathname.new(full_path).relative_path_from(Pathname.new(ROOT_DIR)).to_s
    end

    def full_path
      File.expand_path(File.join(filepath, filename))
    end

    def select_appropriate_versions(versions)
      sorted_versions = versions.compact.sort
      prev_last_version, last_version = sorted_versions.last(2)
      return prev_last_version unless last_version
      diff = last_version - prev_last_version
      is_appropriate = diff.major == 1
      is_appropriate ||= diff.major == 0 && diff.minor == 1
      is_appropriate ||= diff.major == 0 && diff.minor == 0 && diff.patch == 1
      raise WrongLatestVersionError.new(last_version) unless is_appropriate
      last_version
    end
  end
end
