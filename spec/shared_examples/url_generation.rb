RSpec.shared_examples('url generation') { |client_id, secret|
  let(:params) { Rack::Utils.parse_query(URI.parse(url).query) }

  it('has no secret') {
    expect(url).not_to(include(secret))
  }

  it('has client_id') {
    expect(params['client_id']).to(eq(client_id))
  }

  it('passes through state') {
    encoded_state = Base64.urlsafe_encode64(JSON.dump(state), padding: false)
    expect(params['state']).to(eq(encoded_state))
  }
}
