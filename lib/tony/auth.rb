module Tony
  module Auth
    LoginInfo = Struct.new(:email, :info, :state, keyword_init: true)
    public_constant :LoginInfo

    class Base
      @@codes = {}
      def self.code(path)
        @@codes[path] ||= SecureRandom.alphanumeric(24)
        return @@codes[path]
      end

      @@paths = {}
      def initialize(app, client_id:, secret:, path: default_path)
        if ENV['APP_ENV'] != 'test' && @@paths.key?(path)
          raise(ArgumentError,
                "#{self.class} created twice with same path: #{path}")
        end

        @@paths[path] = client_id
        @app = app
        @path = path
        @client_id = client_id
        @secret = secret
      end

      def call(env)
        req = Rack::Request.new(env)
        fetch_login_info(req) if req.path == @path && req.params.key?('code')
        @app.call(env)
      end

      private

      def basic_token
        return Base64.urlsafe_encode64("#{@client_id}:#{@secret}")
      end
    end
  end
end

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each { |file|
  require_relative file unless file == __FILE__
}
