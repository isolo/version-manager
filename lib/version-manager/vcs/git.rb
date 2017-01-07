module VersionManager
  module VCS
    class Git
      def initialize(options)
        @options = options
        @git = ::Git.open(ROOT_DIR, options)
      end

      def create_branch!(branch_name)
        raise VersionManager::VCS::BranchAlreadyExistsError.new(branch_name) if branch_exists?(branch_name)
        checkout(branch_name)
      end

      def checkout(branch_name)
        git.lib.send(:command, 'checkout', branch_name)
      end

      def show_file(branch, filepath)
        git.object("#{branch}:#{filepath}").contents
      rescue StandardError
        nil
      end

      def commit(filepath, message)
        git.lib.send(:command, 'add', filepath)
        git.lib.send(:command, 'commit', "-m #{message}", '-o', "#{filepath}")
      end

      def add_tag(tag_name, message)
        git.add_tag(tag_name, message: message, annotate: tag_name)
      end

      def push
        git.pull(remote, current_branch) if find_remote_branch(current_branch)
        git.push(remote, current_branch)
      end

      def push_tag(tag_name)
        git.push(remote, tag_name)
      end

      def current_branch
        git.current_branch
      end

      def master_state_actual?
        git.revparse(master_branch_name) == git.revparse(remote_master_branch_name)
      end

      def state_actual?
        head = ::Git.ls_remote['branches'][git.current_branch]
        remote_head = find_remote_branch(git.current_branch).last
        return unless remote_head
        head[:sha] == remote_head[:sha]
      end

      def remote_branch_names
        ::Git.ls_remote['remotes'].keys
      end

      private

      attr_reader :git, :options

      def branch_exists?(branch_name)
        branches = ::Git.ls_remote['branches'].keys + ::Git.ls_remote['remotes'].keys
        branches.any? { |b| b.split('/').last == branch_name }
      end

      def master_branch_name
        options[:master_branch]
      end

      def remote
        options[:remote]
      end

      def remote_master_branch_name
        "#{options[:remote]}/#{master_branch_name}"
      end

      def find_remote_branch(branch_name)
        ::Git.ls_remote['remotes'].find { |remote, _| branch_name == remote.split('/').last }
      end
    end
  end
end
