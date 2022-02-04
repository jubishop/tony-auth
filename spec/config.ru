require_relative '../lib/tony/auth'
require_relative '../lib/tony/google'

GOOGLE_CLIENT_ID = 'client_id'.freeze
GOOGLE_SECRET = 'secret'.freeze

use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID, secret: GOOGLE_SECRET
use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID,
                        secret: GOOGLE_SECRET,
                        path: '/some_other_auth/google'

response = ->(req, resp) {
  return 404, 'No login_info' unless req.env.key?('login_info')

  resp.write(req.env['login_info'].email)
  resp.write(req.env['login_info'].state)
}

tony = Tony::App.new
tony.get('/auth/google', response)
tony.get('/some_other_auth/google', response)

run tony
