require 'base64'
require 'core'
require 'json'
require 'net/http'

module Tony
  module Auth
    class Google < Base
      @@paths = {}
      def self.url(req, path: '/auth/google', scope: 'email', **state)
        client_id = @@paths.fetch(path)
        uri = URI('https://accounts.google.com/o/oauth2/v2/auth')
        uri.query = URI.encode_www_form(
            client_id: client_id,
            redirect_uri: "#{req.base_url}#{path}",
            response_type: 'code',
            scope: scope,
            state: Base64.urlsafe_encode64(JSON.dump(state), padding: false))
        return uri.to_s
      end

      private

      def default_path
        return '/auth/google'
      end

      def fetch_login_info(req)
        response = Net::HTTP.post_form(
            URI('https://oauth2.googleapis.com/token'),
            client_id: @client_id,
            client_secret: @secret,
            code: req.params.fetch('code'),
            grant_type: 'authorization_code',
            redirect_uri: "#{req.base_url}#{@path}")
        info = JSON.parse(response.body).symbolize_keys!

        uri = URI('https://oauth2.googleapis.com/tokeninfo')
        uri.query = URI.encode_www_form(id_token: info.fetch(:id_token))
        response = Net::HTTP.get_response(uri)
        info = JSON.parse(response.body).symbolize_keys!

        state = JSON.parse(
            Base64.urlsafe_decode64(req.params.fetch('state', 'e30=')))
        state.symbolize_keys!
        req.env['login_info'] = LoginInfo.new(email: info.fetch(:email),
                                              info: info,
                                              state: state)
      end
    end
  end
end
