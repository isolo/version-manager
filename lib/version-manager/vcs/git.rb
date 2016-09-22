module VersionManager
  module VCS
    class Git
      def initialize
        @git = ::Git.open(ROOT_DIR)
      end

      def current_branch
        git.branch.name
      end

      def master_state_actual?
        git.revparse(master_branch_name) == git.revparse(remote_master_branch_name)
      end

      def state_actual?
        head = ::Git.ls_remote['head']
        remote_head = find_remote_branch('HEAD').last
        return unless remote_head
        head[:sha] == remote_head[:sha]
      end

      private

      attr_reader :git

      def master_branch_name
        VersionManager.options[:master_branch]
      end

      def remote_master_branch_name
        find_remote_branch(master_branch_name).first
      end

      def find_remote_branch(branch_name)
        ::Git.ls_remote['remotes'].find { |remote, _| branch_name == remote.split('/').last }
      end
    end
  end
end
