require 'base64'
require 'core'
require 'json'
require 'net/http'
require 'uri'

module Tony
  module Auth
    class Facebook < Base
      def self.url(req, path: '/auth/facebook', scope: 'email', **state)
        client_id = @@paths.fetch(path)
        uri = URI('https://www.facebook.com/v12.0/dialog/oauth')
        uri.query = URI.encode_www_form(
            client_id: client_id,
            redirect_uri: "#{req.base_url}#{path}",
            scope: scope,
            state: Base64.urlsafe_encode64(JSON.dump(state), padding: false))
        return uri.to_s
      end

      private

      def default_path
        return '/auth/facebook'
      end

      def fetch_login_info(req)
        uri = URI.parse('https://graph.facebook.com/v12.0/oauth/access_token')
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(client_id: @client_id,
                              client_secret: @secret,
                              code: req.params.fetch('code'),
                              redirect_uri: "#{req.base_url}#{@path}")
        req_options = { use_ssl: uri.scheme == 'https' }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http|
          http.request(request)
        }
        info = JSON.parse(response.body).symbolize_keys!

        uri = URI.parse('https://graph.facebook.com/me')
        uri.query = URI.encode_www_form(fields: 'email',
                                        access_token: info[:access_token])
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
