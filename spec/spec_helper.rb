begin
  require 'byebug'
rescue LoadError
  nil
end

require 'securerandom'

require 'version-manager'
require_relative 'support/git_repository'

RSpec.configure do |config|
  config.order = :random
end
