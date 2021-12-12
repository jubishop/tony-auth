# tony-auth

[![RSpec Status](https://github.com/jubishop/tony-auth/workflows/RSpec/badge.svg)](https://github.com/jubishop/tony-auth/actions/workflows/rspec.yml)  [![Rubocop Status](https://github.com/jubishop/tony-auth/workflows/Rubocop/badge.svg)](https://github.com/jubishop/tony-auth/actions/workflows/rubocop.yml)

Middlewares to help login with 3rd party services.

## Installation

### In a Gemfile

```ruby
source: 'https://www.jubigems.org/' do
  gem 'tony-auth'
end
```

## Usage

### Google

In your config.ru, you can add:

```ruby
use Tony::Auth::Google, client_id: google_client_id, secret: google_secret
```

In a view file, you can link to log in like this:

```ruby
a href=Tony::Auth::Google.url(req, redirect: '/') Sign in with Google
```

`req` should be an instance of [`Rack::Request`](https://github.com/rack/rack/blob/master/lib/rack/request.rb) associated with the current request.

You may pass any other key value pairs you wish (in this case, `redirect: '/'`), and they will get passed back to you in the `state` variable.

Finally, in your controller, add a hook for `/auth/google`.  The `req.env[:login_info]` will be an object with an `email` and `state` attribute:

```ruby
get('/auth/google', ->(req, resp) {
  login_info = req.env[:login_info]
  resp.set_cookie(:email_address, login_info.email)
  resp.redirect(login_info.state[:redirect])
})
```

## Testing Code that Uses `tony-auth`

Testing `tony-auth` endpoints can be tricky at first glance.  Here's how you could test in `RSpec` and `rack-test` (using `tony-test`) the `/auth/google` endpoint in the example provided above.

```ruby
require 'securerandom'

RSpec.describe(Main, type: :rack_test) {
  context('get /auth/google') {
    before(:each) {
      allow(Tony::Auth::Google).to(receive(:url)).and_return(
          SecureRandom.alphanumeric(24))
      @login_info = Tony::Auth::LoginInfo.new(email: 'test@email.com',
                                              state: { redirect: '/onward' })
    }

    it('sets the email address') {
      set_cookie(:email, 'nomnomnom')
      get '/auth/google', {}, { 'login_info' => @login_info }
      expect(get_cookie(:email)).to(eq('test@email.com'))
    }

    it('redirects to :r in state') {
      get '/auth/google', {}, { 'login_info' => @login_info }
      expect(last_response.redirect?).to(be(true))
      expect(last_response.location).to(eq('/onward'))
    }
  }
}
```

## More Documentation

- [Rubydoc](https://www.rubydoc.info/github/jubishop/tony-auth/master)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
