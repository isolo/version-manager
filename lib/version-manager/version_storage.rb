module VersionManager
  class VersionStorage
    def initialize
      @filename = VersionManager.options[:storage][:filename]
      @filepath = VersionManager.options[:storage][:filepath]
    end

    def store(version)
      File.open(full_path) do |file|
        file << version
      end
    end

    private

    attr_reader :filename, :filepath

    def full_path
      File.expand_path(File.join(filepath, filename))
    end
  end
end
