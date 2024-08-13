# frozen_string_literal: true

require "postlicensed"

module Helper
  def fixture_path(path)
    File.join(__dir__, "fixtures", path)
  end

  def suppress_stdout
    backup = $stdout
    File.open(File::NULL, "w") do |file|
      $stdout = file
      yield
    end
  ensure
    $stdout = backup
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include(Helper)
end
