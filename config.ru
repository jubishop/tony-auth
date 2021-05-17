require_relative 'lib/tony/auth'
require_relative 'lib/tony/google'

GOOGLE_CLIENT_ID = %(
  839410869904-cjchcdghsaqmlh3s9c9pjm54j3nqdsmf.apps.googleusercontent.com
).strip.freeze
GOOGLE_SECRET = 'ZN2HPihD6y38yErT4JJ6FLLq'.freeze

use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID, secret: GOOGLE_SECRET

tony = Tony::App.new
tony.get('/auth/google', ->(req, resp) {
  resp.write(req.env[:login_info].email)
  resp.write(req.env[:login_info].state)
})

run tony
