# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
RSpec.describe 'bumping version' do
  include_context 'shared settings'
  let(:repo) { VersionManager::GitRepository.new(root_dir, options) }
  let(:default_confirmation_func) { ->(_new_version) { true } }

  def release_new_version(release_type, confirmation_func = default_confirmation_func, retrieve_init_version_func = nil)
    VersionManager::ActionManager
      .new(options)
      .release_new_version(release_type, confirmation_func, retrieve_init_version_func)
  end

  context 'when repository does not contains any versions' do
    let(:initial_version) { VersionManager::ReleaseVersion.new('1.0.0') }
    it 'retrieves an initial version' do
      repo.init
      retrieve_initial_version_func = ->() { initial_version }

      release_new_version(:major, default_confirmation_func, retrieve_initial_version_func)

      expect(repo.current_local_branch_version).to eq(initial_version.bump_major.to_s)
      # Add tag check
    end
  end

  context 'when initial version is presented' do
    let(:initial_version) { VersionManager::ReleaseVersion.new('1.0.0') }
    let(:current_version) { initial_version.bump_major }
    before do
      repo.init
      retrieve_initial_version_func = ->() { initial_version }
      release_new_version(:major, default_confirmation_func, retrieve_initial_version_func)
      repo.checkout_to_master_branch
    end

    context 'when current branch is a master branch' do
      it 'bumped major version' do
        release_new_version(:major)
        expect(repo.current_local_branch_version).to eq(current_version.bump_major.to_s)
      end

      it 'bumped minor version' do
        release_new_version(:minor)
        expect(repo.current_local_branch_version).to eq(current_version.bump_minor.to_s)
      end

      it 'does not bump patch version' do
        expect { release_new_version(:patch) }.to(
          raise_error(VersionManager::ReleaseManager::ForbiddenBranchError)
        )
      end
    end
  end
end
