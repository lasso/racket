describe 'An invalid Racket test Application' do
  extend Rack::Test::Methods

  def app
    @app ||= Racket::Application.default
  end

  it 'should never initialize' do
    -> { get '/' }
      .should.raise(RuntimeError)
      .message.should.equal('Application has already been initialized!')
  end
end
