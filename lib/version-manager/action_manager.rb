# frozen_string_literal: true
module VersionManager
  class ActionManager
    def initialize(options)
      @options = options
      @vcs = VCS.build(options[:vcs])
      @storage = VersionStorage.new(vcs, options[:storage])
      @release_manager = ReleaseManager.new(vcs, storage, options)
    end

    def checkout_to_latest_version
      version = storage.latest_version
      return false unless version
      vcs.switch_branch(VCS.branch_name(version, options.dig(:vcs, :options)))
      true
    end

    def release_new_version(release_type, confirmation_func, retrieve_initial_version_func)
      release_manager.validate!(release_type)
      version = release_type == :patch ? storage.current_version : storage.latest_version
      if version
        new_version = version.public_send("bump_#{release_type}")
        return unless confirmation_func.call(new_version)
      else
        version = retrieve_initial_version_func.call
      end
      release_manager.public_send("#{release_type}!", version)
    end

    private

    attr_reader :vcs, :storage, :release_manager, :options
  end
end
