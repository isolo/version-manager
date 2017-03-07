module VersionManager
  class ReleaseManager
    class BranchIsNotUpToDateError < StandardError
      def message
        'Remote branch and local one are different. You need to update your branch or push your changes'
      end
    end

    class ForbiddenBranchError < StandardError
      def message
        'You can not do actions from this branch. Checkout to appropriate branch'
      end
    end

    def initialize(vcs, version_storage, options)
      @vcs = vcs
      @version_storage = version_storage
      @options = options
    end

    def validate!(release_type)
      raise BranchIsNotUpToDateError unless vcs.master_state_actual?
      raise ForbiddenBranchError unless appropriate_branch_for?(release_type)
    end

    def major!(version)
      default_strategy(version.bump_major)
    end

    def minor!(version)
      default_strategy(version.bump_minor)
    end

    def patch!(version)
      version = version.bump_patch
      vcs.commit(version_storage.store(version), default_commit_message(version))
      vcs.add_tag(version.to_s, default_commit_message(version))
      vcs.push_tag(version.to_s)
      vcs.push
    end

    private

    attr_reader :vcs, :version_storage, :options

    def appropriate_branch_for?(action)
      authorized_mask = options[:authorized_branches][action.to_sym]
      !authorized_mask || !vcs.current_branch.match(authorized_mask).nil?
    end

    def default_strategy(version)
      vcs.create_branch!(version.branch)
      vcs.commit(version_storage.store(version), default_commit_message(version))
      vcs.add_tag(version.to_s, default_commit_message(version))
      vcs.push_tag(version.to_s)
      vcs.push
    end

    def default_commit_message(version)
      message = options[:vcs][:default_commit_message]
      message.respond_to?(:call) ? message.call(version) : message.to_s
    end
  end
end
