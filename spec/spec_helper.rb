require 'bundler/setup'
require 'rubocop/require_tools'

require 'rubocop/rspec/support'

# Add strip_indent helper for compatibility
class String
  def strip_indent
    indent = scan(/^[ \t]*(?=\S)/).min
    indent_size = indent ? indent.size : 0
    gsub(/^[ \t]{#{indent_size}}/, '')
  end
end

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end
