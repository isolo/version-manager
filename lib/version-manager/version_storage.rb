# frozen_string_literal: true
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
      versions = vcs.remote_branch_names.map(&method(:version_from_branch_name))
      version = select_appropriate_version(versions) # It's a partial release version (only major and minor parts)
      version_from_file(version)
    end

    def current_version
      version = version_from_branch_name(vcs.current_branch)
      raise ArgumentError, 'Can not detect a current version' unless version
      version_from_file(version)
    end

    private

    attr_reader :filename, :filepath, :vcs

    def version_from_file(version)
      return unless version
      file_content = vcs.show_file(version, full_path) if version
      ReleaseVersion.new(file_content) if file_content && ReleaseVersion.valid?(file_content)
    end

    def version_from_branch_name(branch_name)
      return unless branch_name
      branch_name = branch_name.split('/').last
      ReleaseVersion.new(branch_name) if branch_name.include?('release-') && ReleaseVersion.valid?(branch_name)
    end

    def full_path
      File.expand_path(File.join(filepath, filename))
    end

    def select_appropriate_version(versions)
      sorted_versions = versions.compact.sort
      prev_last_version, last_version = sorted_versions.last(2)
      return prev_last_version unless last_version
      diff = last_version - prev_last_version
      is_appropriate = diff.major == 1
      is_appropriate ||= diff.major.zero? && diff.minor == 1
      is_appropriate ||= diff.major.zero? && diff.minor.zero? && diff.patch == 1
      raise WrongLatestVersionError, last_version unless is_appropriate
      last_version
    end
  end
end
