# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
RSpec.describe 'latest version action' do
  include_context 'shared settings'
  let(:repo) { Test::GitRepository.new(root_dir, options) }

  def checkout_to_latest_version
    VersionManager::ActionManager.new(options).checkout_to_latest_version
  end

  context 'when a repository does not contain any versions' do
    before { repo.init }
    it 'do nothing' do
      expect(checkout_to_latest_version).to be_falsy
    end
  end

  context 'when a repository has several releases' do
    let(:initial_version) { VersionManager::ReleaseVersion.new('1.0.0') }
    let(:current_version) { @current_version }
    before do
      repo.init
      @current_version = initial_version
      retrieve_initial_version_func = ->() { initial_version }
      (1..10).to_a.sample.times do
        release_type = %i(major minor).sample
        @current_version = @current_version.bump(release_type)
        release_new_version(release_type, default_confirmation_func, retrieve_initial_version_func)
        repo.checkout_to_master_branch
      end
    end

    it 'checkouts to latest version' do
      expect(checkout_to_latest_version).to be_truthy
      expect(repo).to have_version(current_version)
      expect(repo).to have_tag(current_version)
      expect(repo).to have_branch(release_name(current_version))
    end
  end

  after(:each) do
    repo.teardown if tmp_dir?
  end
end
