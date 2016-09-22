require 'docopt'
require 'git'

module VersionManager
  DEFAULTS = {
    master_branch: 'master',
    vcs: 'git',
    authorized_branches: {
      release: '^\bmaster\b$',
      hotfix: '^\brelease-[a-zA-Z0-9.]*$\b$'
    }
  }

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.options=(opts)
    @options = opts
  end
end

ROOT_DIR = File.expand_path(File.join(__FILE__, '..', '..'))

require_relative 'version-manager/vcs'
require_relative 'version-manager/vcs/git'

require_relative 'version-manager/version'
require_relative 'version-manager/cli'
