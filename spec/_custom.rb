describe 'The custom Racket test Application' do
  extend Rack::Test::Methods
  def app
    @app ||= Racket::Application.using(default_layout: 'zebra.*', view_dir: 'templates')
  end

  it 'should set requested options' do
    app.options[:default_layout].should.equal('zebra.*')
    app.options[:view_dir].should.equal('templates')
  end

  it 'should be able to get/set options on controller' do
    get '/sub3/a_secret_place'
    last_response.status.should.equal(302)
    last_response.headers['Location'].should.equal('/sub3/a_secret_place/42')
    last_response.body.length.should.equal(0)
  end

  it 'should return a 404 on a nonexisting url' do
    get '/nosuchurl'
    last_response.status.should.equal(404)
    last_response.body.should.equal('404 Not found')
  end

  it 'should be able to render a template and a layout' do
    get '/sub2/template'
    last_response.status.should.equal(200)
    last_response.body.should.match(/Message from template/)
    last_response.body.should.match(/A groovy layout/)
  end
end
