require 'webmock/rspec'
require 'cgi'

require_relative '../lib/tony/github'
require_relative 'shared_examples/assertions'
require_relative 'shared_examples/loginable'
require_relative 'shared_examples/url_generation'

RSpec.describe(Tony::Auth::Github, type: :rack_test) {
  context('url generation') {
    let(:state) { { key: 'value' } }
    let(:url) {
      Tony::Auth::Github.url(FakeRequest.new('base_url'), key: 'value')
    }

    it_has_behavior('url generation', GITHUB_CLIENT_ID, GITHUB_SECRET)
  }

  shared_context('login') { |auth_path|
    before(:each) {
      stub_request(
          :post,
          'https://github.com/login/oauth/access_token').with { |request|
            CGI.parse(request.body).symbolize_keys! == {
              client_id: [GITHUB_CLIENT_ID],
              client_secret: [GITHUB_SECRET],
              code: [AUTH_CODE],
              redirect_uri: ["http://example.org#{auth_path}"]
            } && request.headers.fetch('Accept') == 'application/json'
          }
        .to_return(body: JSON.dump({ access_token: 'github_access_token' }))

      stub_request(
          :get,
          'https://api.github.com/user').with(
              headers: {
                Authorization: 'token github_access_token'
              })
        .to_return(body: JSON.dump({ email: USER_EMAIL }))
    }
  }

  context('/auth/github') {
    include_context('login', '/auth/github')
    it_has_behavior('loginable', '/auth/github')
  }

  context('/some_other_auth/github') {
    include_context('login', '/some_other_auth/github')
    it_has_behavior('loginable', '/some_other_auth/github')
  }

  context('assertions') {
    let(:auth_instance) {
      Tony::Auth::Github.new(nil, client_id: 'id', secret: 'secret')
    }
    it_has_behavior('assertions', 'Tony::Auth::Github', '/auth/github')
  }
}
