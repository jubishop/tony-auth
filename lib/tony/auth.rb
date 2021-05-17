Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each { |file|
  require_relative file unless file == __FILE__
}

module Tony
  module Auth
    LoginInfo = Struct.new(:email, :state, keyword_init: true)
    public_constant :LoginInfo
  end
end
