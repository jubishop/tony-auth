require_relative '../lib/tony/auth'
require_relative '../lib/tony/google'

GOOGLE_CLIENT_ID = 'client_id'.freeze
GOOGLE_SECRET = 'secret'.freeze

use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID, secret: GOOGLE_SECRET
use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID,
                        secret: GOOGLE_SECRET,
                        path: '/some_other_auth/google'

tony = Tony::App.new
tony.get('/auth/google', ->(req, resp) {
  resp.write(req.env['login_info'].email)
  resp.write(req.env['login_info'].state)
})
tony.get('/some_other_auth/google', ->(req, resp) {
  resp.write(req.env['login_info'].email)
  resp.write(req.env['login_info'].state)
})

run tony
