describe 'A Racket verbs test application' do
  extend Rack::Test::Methods

  def app
    @app ||= Racket::Application.default
  end

  it 'returns the correct response when calling postMe action' do
    # FirstVerbsController
    post '/getMe'
    last_response.status.should.equal(405)
    last_response.body.should.equal('405 Method Not Allowed')
  end
end
