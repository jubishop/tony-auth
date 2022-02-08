# tony-auth

[![RSpec Status](https://github.com/jubishop/tony-auth/workflows/RSpec/badge.svg)](https://github.com/jubishop/tony-auth/actions/workflows/rspec.yml)  [![Rubocop Status](https://github.com/jubishop/tony-auth/workflows/Rubocop/badge.svg)](https://github.com/jubishop/tony-auth/actions/workflows/rubocop.yml)

Middlewares to help login with 3rd party services.

## Installation

### In a Gemfile

```ruby
source: 'https://www.jubigems.org/' do
  gem 'core'
  gem 'tony-auth'
end
```

## Usage

## Standardized Interface

The interface for each class is the same except for their default `path`.  The classes supported are:

- Google: `Tony::Auth::Google`, `/auth/google`
- Github: `Tony::Auth::Github`, `/auth/github`

### Twitter

Twitter does not work until an OAuth V2 replacement is announced for `account/verify_credentials`.

- Twitter: `Tony::Auth::Twitter`, `/auth/twitter`

### Google (Full Example)

Here is an example of how you'd use `Tony::Auth::Google`.  The approach would be the same for all other classes.

In your config.ru, you can add:

```ruby
use Tony::Auth::Google, client_id: google_client_id, secret: google_secret
```

In a view file, you can link to log in like this:

```ruby
a href=Tony::Auth::Google.url(req, redirect: '/') Sign in with Google
```

`req` should be an instance of [`Rack::Request`](https://github.com/rack/rack/blob/master/lib/rack/request.rb) associated with the current request.

If you want to have a different path than `/auth/google`, you can pass it as `path:`.  Finally, if you want to request a scope beyond simply `email`, you can pass it as `scope:`.  The entire JSON decoded object returned from Google will be given in the `info` attribute.  You may pass any other key value pairs you wish (in this case, `redirect: '/'`), and they will get passed back to you in the `state` attribute.

Finally, in your controller, add a hook for `/auth/google` (or whatever you set your `path:` to).  The `req.env[:login_info]` will be a `LoginInfo` object with an `email`, `info`, and `state` attribute:

```ruby
get('/auth/google', ->(req, resp) {
  login_info = req.env[:login_info]
  resp.set_cookie(:email_address, login_info.email)
  puts "Full JSON object given is: #{login_info.info}"
  resp.redirect(login_info.state.fetch(:redirect, '/'))
})
```

## Testing Code that Uses `tony-auth`

Testing `tony-auth` endpoints can be tricky at first glance.  Here's how you could test in `RSpec` and `rack-test` (using `tony-test`) the `/auth/google` endpoint in the example provided above.

```ruby
require 'securerandom'

RSpec.describe(Main, type: :rack_test) {
  context('get /auth/google') {
    let(:login_info) {
      Tony::Auth::LoginInfo.new(email: 'test@email.com',
                                              state: { redirect: '/onward' })
    }

    before(:each) {
      allow(Tony::Auth::Google).to(receive(:url)).and_return(
          SecureRandom.alphanumeric(24))
    }

    it('sets the email address') {
      set_cookie(:email, 'nomnomnom')
      get '/auth/google', {}, { 'login_info' => login_info }
      expect(get_cookie(:email)).to(eq('test@email.com'))
    }

    it('redirects to :redirect in state') {
      get '/auth/google', {}, { 'login_info' => login_info }
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
