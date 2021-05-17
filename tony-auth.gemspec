Gem::Specification.new do |spec|
  spec.name          = 'tony-auth'
  spec.version       = '0.6'
  spec.summary       = %q(Middlewares to help login with 3rd party services.)
  spec.authors       = ['Justin Bishop']
  spec.email         = ['jubishop@gmail.com']
  spec.homepage      = 'https://github.com/jubishop/tony-auth'
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.metadata      = {
    'source_code_uri' => 'https://github.com/jubishop/tony-auth'
  }
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')
  spec.add_dependency('base64')
end
