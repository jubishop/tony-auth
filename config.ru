require_relative 'lib/tony/auth'
require_relative 'lib/tony/google'

google_client_id =
  '839410869904-cjchcdghsaqmlh3s9c9pjm54j3nqdsmf.apps.googleusercontent.com'
google_secret = 'ZN2HPihD6y38yErT4JJ6FLLq'
use Tony::Auth::Google, client_id: google_client_id, secret: google_secret

tony = Tony::App.new
tony.get('/auth/google', ->(req, resp) {
  resp.write(req.env[:login_info].email)
  resp.write(req.env[:login_info].state)
})

run tony
