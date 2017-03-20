RSpec.shared_context 'shared settings' do
  let(:root_dir) { Dir.mktmpdir }
  let(:repo_dir) { File.join(root_dir, 'local') }

  let(:vcs) { 'git' }
  let(:default_commit_message) do
    ->(version) { "Bumped to version #{version}" }
  end
  let(:vcs_opts) do
    {
      name: vcs,
      default_commit_message: default_commit_message,
      options: {
        remote: 'origin',
        master_branch: 'master',
        dir: repo_dir,
        version_name: ->(version) { "release-#{version.short_version}" },
      }
    }
  end

  let(:authorized_branches_opts) do
    {
      major: '^\bmaster\b$',
      minor: '^\bmaster\b$',
      patch: '^\brelease-[a-zA-Z0-9.]*$\b$'
    }
  end

  let(:storage_opts) do
    {
      filename: 'VERSION',
      filepath: repo_dir
    }
  end

  let(:options) do
    {
      vcs: vcs_opts,
      authorized_branches: authorized_branches_opts,
      storage: storage_opts
    }
  end
end
