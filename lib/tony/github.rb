require 'core'
require 'json'
require 'net/http'
require 'uri'

module Tony
  module Auth
    class Github < Base
      def self.url(req, path: '/auth/github', scope: 'user:email', **state)
        client_id = @@paths.fetch(path)
        uri = URI('https://github.com/login/oauth/authorize')
        uri.query = URI.encode_www_form(
            client_id: client_id,
            redirect_uri: "#{req.base_url}#{path}",
            scope: scope,
            state: Base64.urlsafe_encode64(JSON.dump(state), padding: false))
        return uri.to_s
      end

      private

      def default_path
        return '/auth/github'
      end

      def fetch_login_info(req)
        uri = URI.parse('https://github.com/login/oauth/access_token')
        request = Net::HTTP::Post.new(uri)
        request['Accept'] = 'application/json'
        request.set_form_data(client_id: @client_id,
                              client_secret: @secret,
                              code: req.params.fetch('code'),
                              redirect_uri: "#{req.base_url}#{@path}")
        req_options = { use_ssl: uri.scheme == 'https' }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http|
          http.request(request)
        }
        info = JSON.parse(response.body).symbolize_keys!

        uri = URI.parse('https://api.github.com/user')
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "token #{info[:access_token]}"
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http|
          http.request(request)
        }
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
