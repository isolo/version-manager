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

    def self.build
      case VersionManager.options[:vcs][:name]
      when 'git' then VersionManager::VCS::Git.new(VersionManager.options[:vcs][:options])
      else raise UnsupportedVCSError
      end
    end
  end
end
