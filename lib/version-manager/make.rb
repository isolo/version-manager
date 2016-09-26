module VersionManager
  class Make
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

    def initialize(version, vcs, version_storage)
      @version = version
      @vcs = vcs
      @version_storage = version_storage
    end

    def major!
      raise BranchIsNotUpToDateError unless vcs.master_state_actual?
      raise ForbiddenBranchError unless appropriate_branch_for?('major')
      default_strategy { |version| version.bump_major }
    end

    def minor!
      raise BranchIsNotUpToDateError unless vcs.master_state_actual?
      raise ForbiddenBranchError unless appropriate_branch_for?('minor')
      default_strategy { |version| version.bump_minor }
    end

    def patch!
      raise BranchIsNotUpToDateError unless vcs.state_actual?
      raise ForbiddenBranchError unless appropriate_branch_for?('patch')
      version.bump_patch
      vcs.commit(version_storage.store(version), default_commit_message)
    end

    private

    attr_reader :version, :vcs, :version_storage

    def appropriate_branch_for?(action)
      authorized_mask = VersionManager.options[:authorized_branches][action]
      !authorized_mask || !vcs.current_branch.match(authorized_mask).nil?
    end

    def branch_name
      "release-#{version.to_s}"
    end

    def default_strategy
      yield version
      vcs.create_branch!(branch_name)
      vcs.commit(version_storage.store(version), default_commit_message)
      vcs.add_tag(version.to_s, default_commit_message)
      vcs.push_tag(version.to_s)
      vcs.push
    end

    def default_commit_message
      message = VersionManager.options[:vcs][:default_commit_message]
      message.respond_to?(:call) ? message.call(version) : message.to_s
    end
  end
end
