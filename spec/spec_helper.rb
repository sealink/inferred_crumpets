require "bundler/setup"
require "rails"
require "action_controller"
require "action_view"
require "crumpet"
require "inferred_crumpets"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
