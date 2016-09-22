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

    def initialize(version, vsc)
      @version = version
      @vcs = vcs
    end

    def release!
      raise BranchIsNotUpToDateError unless vcs.master_state_actual?
      raise ForbiddenBranchError unless appropriate_branch?(__method__)
      vcs.create_branch!(branch_name)
    end

    def hotfix!
      raise BranchIsNotUpToDateError unless vcs.state_actual?
      raise ForbiddenBranchError unless appropriate_branch?(__method__)
    end

    private

    attr_reader :version, :vcs

    def appropriate_branch?(action)
      authorized_mask = VersionManager.options[:authorized_branches][action]
      !authorized_branch || !vcs.current_branch.match(authorized_mask).nil?
    end

    def branch_name
      "remote-#{version.to_s}"
    end
  end
end
