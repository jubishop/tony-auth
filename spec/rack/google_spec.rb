require_relative '../../lib/tony/google'

FakeRequest = Struct.new(:base_url)

RSpec.describe(Tony::Auth::Google, type: :rack_test) {
  context('url generation') {
    before(:each) {
      @url = Tony::Auth::Google.url(FakeRequest.new('base_url'))
      @params = Rack::Utils.parse_query(URI.parse(@url).query)
    }

    it('has no secret') {
      expect(@url).not_to(include(GOOGLE_SECRET))
    }

    it('has client_id') {
      expect(@params['client_id']).to(eq(GOOGLE_CLIENT_ID))
    }
  }
}
