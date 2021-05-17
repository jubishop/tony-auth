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

The `state` variable will hold whatever key/value pairs you pass (in this case, `redirect: '/'`).

Finally, in your controller, add a hook for `/auth/google`.  The `req.env[:login_info]` will be an object with an `email` and `state` attribute:

```ruby
get('/auth/google', ->(req, resp) {
  login_info = req.env[:login_info]
  resp.set_cookie(:email_address, login_info.email)
  resp.redirect(login_info.state[:redirect])
})
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
