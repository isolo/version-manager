module VersionManager
  module VCS
    class BranchAlreadyExistsError < StandardError
      def initialize(branch_name)
        @branch_name = branch_name
      end

      def message
        "Branch #{@branch_name} already exists"
      end
    end

    class UnsupportedVCSError < StandardError
      def initialize(vcs)
        @vcs = vcs
      end

      def message
        "VCS #{vcs} has not been supported yet"
      end
    end

    def self.branch_name(version, vcs_options)
      version = version.to_s if version.is_a?(ReleaseVersion)
      vcs_options[:version_name].call(version)
    end

    def self.build(vcs_options)
      case vcs_options[:name]
      when 'git' then VersionManager::VCS::Git.new(vcs_options)
      else raise UnsupportedVCSError
      end
    end
  end
end
