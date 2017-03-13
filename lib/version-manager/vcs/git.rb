module VersionManager
  module VCS
    class Git
      def initialize(options)
        @options = options
        @git = ::Git.open(options[:dir], options)
      end

      def create_branch!(branch)
        branch = branch_name(branch)
        raise VersionManager::VCS::BranchAlreadyExistsError.new(branch) if branch_exists?(branch)
        checkout(branch)
      end

      def checkout(branch)
        git.branch(branch_name(branch)).checkout
      end

      def switch_branch(branch) # checkout moves commits to new branch
        git.lib.send(:command, 'checkout', branch_name(branch))
      end

      def show_file(branch, filepath)
        relative_filepath = Pathname.new(filepath).relative_path_from(Pathname.new(options[:dir])).to_s
        git.object("#{remote}/#{branch_name(branch)}:#{relative_filepath}").contents
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
        head = git_remote['branches'][git.current_branch]
        remote_head = find_remote_branch(git.current_branch).last
        return unless remote_head
        head[:sha] == remote_head[:sha]
      end

      def remote_branch_names
        git_remote['remotes'].keys
      end

      private

      attr_reader :git, :options

      def branch_name(version)
        VCS.branch_name(version, options)
      end

      def branch_exists?(branch_name)
        branches = git_remote['branches'].keys + git_remote['remotes'].keys
        branches.any? { |b| b.split('/').last == branch_name }
      end

      def master_branch_name
        options[:master_branch]
      end

      def remote_master_branch_name
        "#{remote}/#{master_branch_name}"
      end

      def find_remote_branch(branch_name)
        remote_branch_names.find { |remote| branch_name == remote.split('/').last }
      end

      def remote
        options[:remote]
      end

      def git_remote
        ::Git.ls_remote(options[:dir])
      end
    end
  end
end
