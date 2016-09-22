class VersionManager::CLI
  def initialize(exec_name: __FILE__)
    @exec_name = exec_name
  end

  def start
    doc = <<~DOCOPT

    Usage:
      #{exec_name} make release
      #{exec_name} make hotfix
      #{exec_name} -h | --help
      #{exec_name} -v | --version

    Options:
      -h --help     show this screen.
      -v --version  show version.
    DOCOPT

    begin
      require 'byebug'
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
  end
end
