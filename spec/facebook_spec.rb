require 'webmock/rspec'
require 'cgi'

require_relative '../lib/tony/facebook'
require_relative 'shared_examples/assertions'
require_relative 'shared_examples/loginable'
require_relative 'shared_examples/url_generation'

RSpec.describe(Tony::Auth::Facebook, type: :rack_test) {
  context('url generation') {
    let(:state) { { key: 'value' } }
    let(:url) {
      Tony::Auth::Facebook.url(FakeRequest.new('base_url'), key: 'value')
    }

    it_has_behavior('url generation', FACEBOOK_CLIENT_ID, FACEBOOK_SECRET)
  }

  shared_context('login') { |auth_path|
    before(:each) {
      stub_request(
          :post,
          'https://graph.facebook.com/v12.0/oauth/access_token').with(
              body: {
                client_id: FACEBOOK_CLIENT_ID,
                client_secret: FACEBOOK_SECRET,
                code: AUTH_CODE,
                redirect_uri: "http://example.org#{auth_path}"
              })
        .to_return(body: JSON.dump({ access_token: 'facebook_access_token' }))

      stub_request(
          :get,
          'https://graph.facebook.com/me').with(
              query: {
                fields: 'email,picture',
                access_token: 'facebook_access_token'
              })
        .to_return(body: JSON.dump({ email: USER_EMAIL }))
    }
  }

  context('/auth/facebook') {
    include_context('login', '/auth/facebook')
    it_has_behavior('loginable', '/auth/facebook')
  }

  context('/some_other_auth/facebook') {
    include_context('login', '/some_other_auth/facebook')
    it_has_behavior('loginable', '/some_other_auth/facebook')
  }

  context('assertions') {
    let(:auth_instance) {
      Tony::Auth::Facebook.new(nil, client_id: 'id', secret: 'secret')
    }
    it_has_behavior('assertions', 'Tony::Auth::Facebook', '/auth/facebook')
  }
}
