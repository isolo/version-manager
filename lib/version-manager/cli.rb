# frozen_string_literal: true
module VersionManager
  class CLI
    def initialize(exec_name: __FILE__)
      @exec_name = exec_name
      @action_manager = ActionManager.new(VersionManager.options)
    end

    def start
      doc = <<~DOCOPT

      Usage:
        #{exec_name} make major
        #{exec_name} make minor
        #{exec_name} make patch
        #{exec_name} latest
        #{exec_name} -h | --help
        #{exec_name} -v | --version

      Options:
        -h --help     show this screen.
        -v --version  show version.
      DOCOPT

      begin
        parse_options(Docopt.docopt(doc))
      rescue StandardError => e
        puts e.message
      end
    end

    private

    attr_reader :exec_name, :action_manager

    def parse_options(options)
      puts VersionManager::VERSION if options['--version']
      checkout_to_latest_version if options['latest']
      %w(major minor patch).each do |release|
        next unless options[release]
        break make_release(release.to_sym)
      end
    end

    def checkout_to_latest_version
      return unless action_manager.checkout_to_latest_version
      puts 'There are no any versions.'
    end

    def make_release(release_type)
      action_manager.release_new_version(release_type, method(:confirm_new_version), method(:retrieve_initial_version))
    rescue VersionManager::VersionStorage::WrongLatestVersionError => e
      puts "There is inappropriate version #{e.version} in your local/remote repository. Please remove it"
    end

    def confirm_new_version(new_version)
      Ask.confirm("You are going to upgrade version to #{new_version}. Do it?", default: false)
    end

    def retrieve_initial_version
      puts 'There are no any versions. Please, input an initial one:'
      ReleaseVersion.new(STDIN.gets)
    rescue ArgumentError => e
      puts e.message
      retry
    end
  end
end
