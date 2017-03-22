# frozen_string_literal: true
begin
  require 'byebug'
rescue LoadError
  nil
end

require 'securerandom'

require 'version-manager'

require_relative 'support/git_repository'
require_relative 'support/shared_settings'
require_relative 'support/repository_matchers'

RSpec.configure do |config|
  config.order = :random
end
