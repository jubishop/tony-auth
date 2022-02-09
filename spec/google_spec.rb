require 'webmock/rspec'

require_relative '../lib/tony/google'
require_relative 'shared_examples/assertions'
require_relative 'shared_examples/loginable'
require_relative 'shared_examples/url_generation'

RSpec.describe(Tony::Auth::Google, type: :rack_test) {
  context('url generation') {
    let(:state) { { key: 'value' } }
    let(:url) {
      Tony::Auth::Google.url(FakeRequest.new('base_url'), key: 'value')
    }

    it_has_behavior('url generation', GOOGLE_CLIENT_ID, GOOGLE_SECRET)
  }

  shared_context('login') { |auth_path|
    before(:each) {
      stub_request(
          :post,
          'https://oauth2.googleapis.com/token').with(
              body: {
                client_id: GOOGLE_CLIENT_ID,
                client_secret: GOOGLE_SECRET,
                code: AUTH_CODE,
                grant_type: 'authorization_code',
                redirect_uri: "http://example.org#{auth_path}"
              })
        .to_return(body: JSON.dump({ id_token: 'google_id_token' }))

      stub_request(
          :get,
          'https://oauth2.googleapis.com/tokeninfo?id_token=google_id_token')
        .to_return(body: JSON.dump({ email: USER_EMAIL }))
    }
  }

  context('/auth/google') {
    include_context('login', '/auth/google')
    it_has_behavior('loginable', '/auth/google')
  }

  context('/some_other_auth/google') {
    include_context('login', '/some_other_auth/google')
    it_has_behavior('loginable', '/some_other_auth/google')
  }

  context('assertions') {
    let(:auth_instance) {
      Tony::Auth::Google.new(nil, client_id: 'id', secret: 'secret')
    }
    it_has_behavior('assertions', 'Tony::Auth::Google', '/auth/google')
  }
}
