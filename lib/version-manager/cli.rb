module VersionManager
  class CLI
    def initialize(exec_name: __FILE__)
      @exec_name = exec_name
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
        parse_options(Docopt::docopt(doc))
      rescue StandardError => e
        puts e.message
      end
    end

    private

    attr_reader :exec_name

    def parse_options(options)
      puts VersionManager::VERSION if options['--version']
      checkout_to_latest_version if options['latest']
      %w(major minor patch).each do |release|
        next unless options[release]
        break make_release(release.to_sym)
      end
    end

    def checkout_to_latest_version
      storage = build_storage
      version = storage.latest_version
      return puts 'There are no any versions.' unless version
      VCS.build.switch_branch(version.branch)
    end

    def make_release(release_type)
      storage = build_storage
      version = storage.latest_version

      new_version = version.public_send("bump_#{release_type}")
      return if version && !Ask.confirm("You are going to upgrade version to #{new_version}. Do it? [Y/n]", default: false)
      version = retrieve_initial_version unless version

      Make.new(version, VCS.build, storage).public_send("#{release_type}!")
    rescue VersionManager::VersionStorage::WrongLatestVersionError => e
      puts "There is inappropriate version #{e.version} in your local/remote repository. Please remove it"
    end

    def build_storage
      storage_options = VersionManager.options[:storage]
      VersionStorage.new(VCS.build, storage_options)
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
