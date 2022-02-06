require 'webmock/rspec'
require 'cgi'

require_relative '../lib/tony/github'

FakeRequest = Struct.new(:base_url)

RSpec.describe(Tony::Auth::Github, type: :rack_test) {
  context('url generation') {
    before(:each) {
      @url = Tony::Auth::Github.url(FakeRequest.new('base_url'), key: 'value')
      @params = Rack::Utils.parse_query(URI.parse(@url).query)
    }

    it('has no secret') {
      expect(@url).not_to(include(GITHUB_SECRET))
    }

    it('has client_id') {
      expect(@params['client_id']).to(eq(GITHUB_CLIENT_ID))
    }

    it('passes through state') {
      state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }),
                                      padding: false)
      expect(@params['state']).to(eq(state))
    }
  }

  shared_examples('login') {
    before(:each) {
      stub_request(
          :post,
          'https://github.com/login/oauth/access_token').with { |request|
            CGI.parse(request.body).symbolize_keys! == {
              client_id: [GITHUB_CLIENT_ID],
              client_secret: [GITHUB_SECRET],
              code: ['github_code'],
              redirect_uri: ["http://example.org#{auth_path}"]
            } && request.headers.fetch('Accept') == 'application/json'
          }
        .to_return(body: '{"access_token": "github_access_token"}')

      stub_request(
          :get,
          'https://api.github.com/user').with(
              headers: {
                Authorization: 'token github_access_token'
              })
        .to_return(body: JSON.dump({ email: 'jubi@github.com' }))
    }

    it('fetches email') {
      state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }),
                                      padding: false)
      get auth_path, { code: 'github_code', state: state }
      expect(last_response.body).to(have_content('jubi@github.com'))
    }

    it('passes through state properly') {
      state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }),
                                      padding: false)
      get auth_path, { code: 'github_code', state: state }
      expect(last_response.body).to(have_content('{:key=>"value"}'))
    }

    it('fails gracefully if no code in request') {
      get auth_path
      expect(last_response.status).to(be(404))
    }
  }

  context('/auth/github') {
    let(:auth_path) { '/auth/github' }
    it_has_behavior 'login'
  }

  context('/some_other_auth/github') {
    let(:auth_path) { '/some_other_auth/github' }
    it_has_behavior 'login'
  }

  context('assertions') {
    it('refuses to create same instance twice in production') {
      ENV['APP_ENV'] = 'production'
      expect { Tony::Auth::Github.new(nil, client_id: 'id', secret: 'secret') }
        .to(raise_error(ArgumentError,
                        /Tony::Auth::Github created twice with same path/))
    }

    it('allows creation of same instance in test context') {
      expect { Tony::Auth::Github.new(nil, client_id: 'id', secret: 'secret') }
        .to_not(raise_error)
    }
  }
}
