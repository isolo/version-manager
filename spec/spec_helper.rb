require 'securerandom'

require 'version-manager'
require_relative 'support/git_repository'

begin
  require 'byebug'
rescue LoadError
  nil
end

# RSpec.configure do |config|
  # config.order :random
# end
