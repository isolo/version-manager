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
        #{exec_name} -h | --help
        #{exec_name} -v | --version

      Options:
        -h --help     show this screen.
        -v --version  show version.
      DOCOPT

      begin
        parse_options(Docopt::docopt(doc))
      rescue Docopt::Exit => e
        puts e.message
      end
    end

    private

    attr_reader :exec_name

    def parse_options(options)
      if options['--version']
        puts VersionManager::VERSION
      end
      %w(major minor patch).each do |release|
        next unless options.keys.include?(release)
        break make_release(release.to_sym)
      end
    end

    def make_release(release_type)
      storage_options = VersionManager.options[:storage]
      storage = VersionStorage.new(VCS.build, storage_options)
      version = storage.latest_version
      version = retrieve_initial_version unless version
      Make.new(version, VCS.build, storage).public_send("#{release_type}!")
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
