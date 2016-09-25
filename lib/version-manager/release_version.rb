module VersionManager
  class ReleaseVersion
    include Comparable

    class IncorrentFormat < StandardError
      def message
        'Incorrect version format. You should pass an array with version components or a string'
      end
    end

    def initialize(version_input)
      version_components = version_input.dup
      version_components = version_input.scan(/(\d+)\.{1}(\d+)\.?(\d*)(?:--(\w+))?/).flatten unless version_input.respond_to?(:to_ary)
      @major, @minor, @patch, @special = version_components
    end

    def to_str
      res = parts.map(&:to_i).join('.')
      [res, special].compact.join('--')
    end

    def short_version
      [major, minor].map(&:to_i).join('.')
    end

    def <=>(other_version)
      parts.zip(other_version.parts).
        map { |this, other| this <=> other }.
        find { |res| res != 0 } || 0
    end

    def bump_major
      @major += 1
      recalculate_parts
    end

    def bump_minor
      @minor += 1
      recalculate_parts
    end

    def bump_patch
      @patch += 1
      recalculate_parts
    end

    attr_reader :major, :minor, :patch, :special, :parts

    private

    def recalculate_parts
      @parts = [@major, @minor, @patch].map(&:to_i)
    end
  end
end
