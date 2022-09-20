require 'simplecov'
SimpleCov.start
require 'bundler/setup'
require 'kontent-ai-delivery'

RSpec.configure do |config|
  ENV['TEST'] = '1'
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
