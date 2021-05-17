require_relative '../lib/tony/google'

FakeRequest = Struct.new(:base_url)

RSpec.describe(Tony::Auth::Google, type: :feature) {
  def login
    fill_in(type: 'email', with: 'jubitester@gmail.com')
    click_button('Next')
    fill_in(type: 'password', with: 'jubitester123')
    click_button('Sign in')
  rescue StandardError => error
    page.driver.save_screenshot('google_login.png', { full: true })
    File.write('google_login.txt', page.body)
    raise error
  end

  it('passes email in LoginInfo') {
    visit(Tony::Auth::Google.url(FakeRequest.new('http://localhost:31337')))
    login
    expect(page).to(have_content('jubitester@gmail.com'))
  }

  it('passes through state in LoginInfo') {
    visit(Tony::Auth::Google.url(FakeRequest.new('http://localhost:31337'),
                                 redirect: '/'))
    login
    begin
      click_button('Allow')
    rescue StandardError
      # Sometimes we don't get this page. /shrug
    end
    File.write('google_login.txt', page.body)
    expect(page).to(have_content(':redirect=>"/"'))
  }
}
