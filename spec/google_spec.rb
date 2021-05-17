require_relative '../lib/tony/google'

FakeRequest = Struct.new(:base_url)

RSpec.describe(Tony::Auth::Google, type: :rack_test) {
  context('url generation') {
    before(:each) {
      @url = Tony::Auth::Google.url(FakeRequest.new('base_url'), key: 'value')
      @params = Rack::Utils.parse_query(URI.parse(@url).query)
    }

    it('has no secret') {
      expect(@url).not_to(include(GOOGLE_SECRET))
    }

    it('has client_id') {
      expect(@params['client_id']).to(eq(GOOGLE_CLIENT_ID))
    }

    it('passes through state') {
      state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }),
                                      padding: false)
      expect(@params['state']).to(eq(state))
    }
  }

  context('fetching login info') {
    before(:each) {
      stub_request(:post, 'https://oauth2.googleapis.com/token').with(
          body: hash_including({ code: 'google_code' })).to_return(
              body: '{"id_token": "google_id_token"}')

      stub_request(
          :get,
          'https://oauth2.googleapis.com/tokeninfo?id_token=google_id_token')
        .to_return(body: JSON.dump({ email: 'jubi@github.com' }))
    }

    it('fetches email') {
      state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }),
                                      padding: false)
      get '/auth/google', { code: 'google_code', state: state }

      expect(last_response.body).to(have_content('jubi@github.com'))
    }

    it('passes through state properly') {
      state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }),
                                      padding: false)
      get '/auth/google', { code: 'google_code', state: state }
      expect(last_response.body).to(have_content('{:key=>"value"}'))
    }
  }

  context('assertions') {
    it('refuses to create same instance twice') {
      expect {
        Tony::Auth::Google.new(nil, client_id: 'id', secret: 'secret')
      }.to(raise_error(ArgumentError))
    }
  }
}
