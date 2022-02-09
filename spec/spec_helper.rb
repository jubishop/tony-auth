require 'tony/test'
require 'webmock/rspec'

ENV['APP_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'

AUTH_CODE = 'auth_code'.freeze
USER_EMAIL = 'user_email'.freeze
GOOGLE_CLIENT_ID = 'google_client_id'.freeze
GOOGLE_SECRET = 'google_secret'.freeze
GITHUB_CLIENT_ID = 'github_client_id'.freeze
GITHUB_SECRET = 'github_secret'.freeze
FACEBOOK_CLIENT_ID = 'facebook_client_id'.freeze
FACEBOOK_SECRET = 'facebook_secret'.freeze

WebMock.disable_net_connect!

FakeRequest = Struct.new(:base_url)

app = Rack::Builder.parse_file('spec/config.ru').first
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

  config.order = :random
  Kernel.srand(config.seed)

  config.include_context(:rack_test, type: :rack_test)

  config.after(:each) {
    ENV['APP_ENV'] = 'test'
    ENV['RACK_ENV'] = 'test'
    Rack::Builder.parse_file('spec/config.ru')
  }
end
