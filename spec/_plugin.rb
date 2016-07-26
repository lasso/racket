describe 'A Racket application with plugins' do
  extend Rack::Test::Methods
  def app
    @app ||= Racket::Application.using(
      logger: nil,
      plugins: [[:sass, { style: :compressed, sourcemap: :none }]]
    )
  end

  it 'should get correct defaults from base plugin' do
    require 'racket/plugins/base'
    plugin = Racket::Plugins::Base.new
    plugin.default_controller_helpers.should.equal([])
    plugin.middleware.should.equal([])
  end

  it 'should return correct CSS paths when querying default controller' do
    get '/css_path'
    last_response.status.should.equal(200)
    last_response.body.should.equal('/css/foo.css')
  end

  it 'should return correct CSS paths when querying a subcontroller' do
    get '/sub/css_path'
    last_response.status.should.equal(200)
    last_response.body.should.equal('/css/sub/bar.css')
  end

  # it 'should render a SASS based stylesheet for the default controller' do
  #   get '/css/test.css'
  #   last_response.status.should.equal(200)
  #   last_response.headers['Content-Type'].should.equal('text/css')
  #   last_response.body.should.equal("body{background-color:snow;color:black}\n")
  # end

  # it 'should render a SASS based stylesheet for a subcontroller' do
  #   get '/css/sub/test.css'
  #   last_response.status.should.equal(200)
  #   last_response.headers['Content-Type'].should.equal('text/css')
  #   last_response.body.should.equal("body{background-color:steelblue;color:gray}\n")
  # end
end
