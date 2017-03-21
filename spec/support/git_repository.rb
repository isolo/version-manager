# frozen_string_literal: true
module VersionManager
  class GitRepository
    def initialize(root_dir, options)
      @options = options
      @root_dir = root_dir
    end

    def init
      remote_dir = File.join(@root_dir, 'remote')
      @remote = Git.init(remote_dir, bare: true)
      @local = Git.clone(remote_dir, 'local', path: @root_dir)
      @local2 = Git.clone(remote_dir, 'local2', path: @root_dir)

      initial_commit(@local)
    end

    def checkout_to_master_branch
      @local.lib.send(:command, 'checkout', @options.dig(:vcs, :options, :master_branch))
    end

    def current_local_branch_version
      path = File.join(@options[:storage][:filepath], @options[:storage][:filename])
      File.open(path).read
    end

    private

    def initial_commit(repo)
      add_random_changes(repo)
      repo.add
      repo.commit('initial commit')
      repo.push
    end

    def add_random_changes(repo)
      File.open(File.join(repo.dir.path, SecureRandom.urlsafe_base64), 'w') do |f|
        f << SecureRandom.urlsafe_base64
      end
    end
  end
end
