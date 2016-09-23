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

    def initialize(version, vsc, version_storage)
      @version = version
      @vcs = vcs
      @version_storage = version_storage
    end

    def major!
      raise BranchIsNotUpToDateError unless vcs.master_state_actual?
      raise ForbiddenBranchError unless aprropriate_branch_for?('release')
      version.bump_major
      vcs.create_branch!(branch_name)
      vcs.commit(version_storage.store(version), "Bumped version to #{version}")
      vcs.push
    end

    def minor!
      raise BranchIsNotUpToDateError unless vcs.master_state_actual?
      raise ForbiddenBranchError unless aprropriate_branch_for?('release')
      version.bump_minor
      vcs.create_branch!(branch_name)
      vcs.commit(version_storage.store(version), "Bumped version to #{version}")
      vcs.push
    end

    def hotfix!
      raise BranchIsNotUpToDateError unless vcs.state_actual?
      raise ForbiddenBranchError unless aprropriate_branch_for?('hotfix')
    end

    private

    attr_reader :version, :vcs, :version_storage

    def aprropriate_branch_for?(action)
      authorized_mask = VersionManager.options[:authorized_branches][action]
      !authorized_branch || !vcs.current_branch.match(authorized_mask).nil?
    end

    def branch_name
      "remote-#{version.to_s}"
    end
  end
end
