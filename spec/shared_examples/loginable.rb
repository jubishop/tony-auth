RSpec.shared_examples('loginable') { |auth_path|
  it('fetches email') {
    state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }), padding: false)
    get auth_path, { code: AUTH_CODE, state: state }
    expect(last_response.body).to(have_content(USER_EMAIL))
  }

  it('passes through state properly') {
    state = Base64.urlsafe_encode64(JSON.dump({ key: 'value' }), padding: false)
    get auth_path, { code: AUTH_CODE, state: state }
    expect(last_response.body).to(have_content('{:key=>"value"}'))
  }

  it('fails gracefully if no code in request') {
    get auth_path
    expect(last_response.status).to(be(404))
  }
}
