require 'tony/test'

app = Rack::Builder.parse_file('config.ru').first
RSpec.shared_context(:rack_test) {
  include_context(:tony_rack_test)

  let(:app) { app }
}

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.default_formatter = 'doc'
  config.alias_it_should_behave_like_to(:it_has_behavior, 'has behavior:')

  config.include_context(:rack_test, type: :rack_test)

  config.order = :random
  Kernel.srand(config.seed)
end
