require_relative '../lib/tony/auth'
require_relative '../lib/tony/google'

use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID, secret: GOOGLE_SECRET
use Tony::Auth::Google, client_id: GOOGLE_CLIENT_ID,
                        secret: GOOGLE_SECRET,
                        path: '/some_other_auth/google'
use Tony::Auth::Github, client_id: GITHUB_CLIENT_ID, secret: GITHUB_SECRET
use Tony::Auth::Github, client_id: GITHUB_CLIENT_ID,
                        secret: GITHUB_SECRET,
                        path: '/some_other_auth/github'
use Tony::Auth::Facebook, client_id: FACEBOOK_CLIENT_ID, secret: FACEBOOK_SECRET
use Tony::Auth::Facebook, client_id: FACEBOOK_CLIENT_ID,
                          secret: FACEBOOK_SECRET,
                          path: '/some_other_auth/facebook'

response = ->(req, resp) {
  return 404, 'No login_info' unless req.env.key?('login_info')

  resp.write(req.env['login_info'].email)
  resp.write(req.env['login_info'].state)
}

tony = Tony::App.new
tony.get('/auth/google', response)
tony.get('/some_other_auth/google', response)
tony.get('/auth/github', response)
tony.get('/some_other_auth/github', response)
tony.get('/auth/facebook', response)
tony.get('/some_other_auth/facebook', response)

run tony
