require 'docopt'
require 'git'

ROOT_DIR = File.expand_path(File.join(__FILE__, '..', '..'))

module VersionManager
  DEFAULTS = {
    master_branch: 'master',
    vcs: 'git',
    authorized_branches: {
      release: '^\bmaster\b$',
      hotfix: '^\brelease-[a-zA-Z0-9.]*$\b$'
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
