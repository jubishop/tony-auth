require 'core'
require 'json'
require 'net/http'
require 'securerandom'
require 'uri'

# This code does not fully work, but is left here for future reference.
module Tony
  module Auth
    class TwitterOAuth2 < Base
      def self.url(req, path: '/auth/twitter', scope: 'users.read', **state)
        client_id = @@paths.fetch(path)
        uri = URI('https://twitter.com/i/oauth2/authorize')
        uri.query = URI.encode_www_form(
            response_type: 'code',
            client_id: client_id,
            redirect_uri: "#{req.base_url}#{path}",
            scope: scope,
            state: Base64.urlsafe_encode64(JSON.dump(state), padding: false),
            code_challenge: code(path),
            code_challenge_method: 'plain')
        return uri.to_s
      end

      private

      def default_path
        return '/auth/twitter'
      end

      def fetch_login_info(req)
        uri = URI.parse('https://api.twitter.com/2/oauth2/token')
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Basic #{basic_token}"
        request.set_form_data(grant_type: 'authorization_code',
                              code: req.params.fetch('code'),
                              client_id: @client_id,
                              redirect_uri: "#{req.base_url}#{@path}",
                              code_verifier: self.class.code(@path))
        req_options = { use_ssl: uri.scheme == 'https' }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http|
          http.request(request)
        }
        info = JSON.parse(response.body).symbolize_keys!
        puts info

        # Forbidden, for some reason?
        uri = URI.parse('https://api.twitter.com/2/users/me')
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{info[:access_token]}"
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http|
          http.request(request)
        }
        info = JSON.parse(response.body).symbolize_keys!
        puts info
      end
    end
  end
end
