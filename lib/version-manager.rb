require 'docopt'
require 'git'
require 'pathname'
require 'logger'
require 'inquirer'

ROOT_DIR = Dir.pwd

module VersionManager
  DEFAULTS = {
    vcs: {
      name: 'git',
      default_commit_message: -> (version) { "Bumped to version #{version}" },
      options: {
        remote: 'origin',
        master_branch: 'master',
        dir: ROOT_DIR,
        version_name: -> (version) { "release-#{version.short_version}" },
      }
    },
    authorized_branches: {
      major: '^\bmaster\b$',
      minor: '^\bmaster\b$',
      patch: '^\brelease-[a-zA-Z0-9.]*$\b$'
    },
    storage: {
      filename: 'VERSION',
      filepath: ROOT_DIR
    }
  }

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.options=(opts)
    @options = opts
  end
end

require_relative 'version-manager/vcs'
require_relative 'version-manager/vcs/git'

require_relative 'version-manager/version'
require_relative 'version-manager/cli'

require_relative 'version-manager/action_manager'
require_relative 'version-manager/release_manager'
require_relative 'version-manager/release_version'
require_relative 'version-manager/version_storage'
