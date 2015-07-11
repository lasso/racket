describe 'A custom Racket test Application' do
  extend Rack::Test::Methods
  def app
    @app ||= Racket::Application.using({ default_layout: 'zebra.*', view_dir: 'templates' }, true)
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

  it 'should be able to require custom files' do
    Module.constants.should.not.include(:Blob)
    Racket.require 'extra/blob'
    Module.constants.should.include(:Blob)
    Module.constants.should.not.include(:InnerBlob)
    Racket.require 'extra', 'blob', 'inner_blob'
    Module.constants.should.include(:InnerBlob)
  end

  it 'should be able to use before/after hooks' do
    get '/sub2/hook_action'
    last_response.headers.key?('X-Hook-Action').should.equal(true)
    last_response.headers['X-Hook-Action'].should.equal('run')
    response = JSON.parse(last_response.body)
    response.should.equal(["Data added in before block", "Data added in action"])
  end
end
