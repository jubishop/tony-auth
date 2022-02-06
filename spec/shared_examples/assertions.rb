RSpec.shared_examples('assertions') { |name, path|
  it('refuses to create same instance twice in production') {
    ENV['APP_ENV'] = 'production'
    expect { auth_instance }
      .to(raise_error(ArgumentError,
                      "#{name} created twice with same path: #{path}"))
  }

  it('allows creation of same instance in test context') {
    expect { auth_instance }.to_not(raise_error)
  }
}
