describe 'A custom Racket test application' do
  extend Rack::Test::Methods
  def app
    @app ||= Racket::Application.using(
      default_layout: 'zebra.*',
      logger: nil,
      my_custom_secret: 42,
      mode: :dev,
      view_dir: 'templates',
      warmup_urls: ['/sub1', '/sub2', '/sub3']
    )
  end

  it 'should be able to locate a resource' do
    Racket.resource_path('files', 'stuff.txt').should.equal(Pathname.new("#{Pathname.pwd}/files/stuff.txt"))
  end

  it 'should set requested settings' do
    settings = app.instance_variable_get(:@registry).application_settings
    settings.default_layout.should.equal('zebra.*')
    view_dir = Pathname.new('templates').cleanpath.expand_path
    settings.view_dir.should.equal(view_dir)
  end

  it 'should get the correct middleware' do
    middleware = app.instance_variable_get(:@registry).application_settings.middleware
    middleware.length.should.equal(3)
    middleware[0].class.should.equal(Array)
    middleware[0].length.should.equal(1)
    middleware[0].first.should.equal(Rack::ShowExceptions)
    middleware[1].class.should.equal(Array)
    middleware[1].length.should.equal(2)
    middleware[1].first.should.equal(Rack::ContentType)
    middleware[2].class.should.equal(Array)
    middleware[2].length.should.equal(2)
    middleware[2].first.should.equal(Rack::Session::Cookie)
  end

  it 'should be able to get/set settings on controller' do
    get '/sub3/a_secret_place'
    last_response.status.should.equal(302)
    last_response.headers['Location'].should.equal('/sub3/a_secret_place/42')
    last_response.body.length.should.equal(0)
    get '/sub3/not_so_secret'
    last_response.status.should.equal(302)
    last_response.headers['Location'].should.equal('/sub3/not_so_secret/21')
    last_response.body.length.should.equal(0)
  end

  it 'should return a 404 on a nonexisting url' do
    get '/nosuchurl'
    last_response.status.should.equal(404)
    last_response.body.should.equal('404 Not Found')
  end

  it 'should be able to render a template and a layout' do
    get '/sub2/template'
    last_response.status.should.equal(200)
    last_response.body.should.match(/Message from template/)
    last_response.body.should.match(/A groovy layout/)
  end

  it 'should be able to require custom files' do
    Module.constants.should.not.include(:Blob)
    app.require 'extra/blob'
    Module.constants.should.include(:Blob)
    Module.constants.should.not.include(:InnerBlob)
    app.require 'extra', 'blob', 'inner_blob'
    Module.constants.should.include(:InnerBlob)
  end

  it 'should be able to use before/after hooks' do
    get '/sub2/hook_action'
    last_response.headers.key?('X-Hook-Action').should.equal(true)
    last_response.headers['X-Hook-Action'].should.equal('run')
    response = JSON.parse(last_response.body)
    response.should.equal(['Data added in before block', 'Data added in action'])
  end

  it 'should let Rack::ShowExceptions handle the error' do
    get '/sub1/epic_fail'
    last_response.status.should.equal(500)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.body.should.match(/^RuntimeError: Epic fail!/)
  end

  it 'should be able to render custom files' do
    get '/sub3/render_a_file'
    last_response.status.should.equal(200)
    last_response.headers['Content-Type'].should.equal('text/html')
    last_response.body.should.equal("The secret is 42!\n")
  end

  it 'should be able to send files with auto mime type' do
    get '/sub1/send_existing_file_auto_mime'
    last_response.status.should.equal(200)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.headers.key?('Content-Disposition').should.equal(false)
    last_response.body.should.equal("This is plain text.\n")
  end

  it 'should be able to send files with custom mime type' do
    get '/sub1/send_existing_file_custom_mime'
    last_response.status.should.equal(200)
    last_response.headers['Content-Type'].should.equal('text/skv')
    last_response.headers.key?('Content-Disposition').should.equal(false)
    last_response.body.should.equal("This is plain text.\n")
  end

  it 'should be able to send unnamed files with Content-Disposition' do
    get '/sub1/send_existing_file_unnamed_attachment'
    last_response.status.should.equal(200)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.headers['Content-Disposition'].should.equal('attachment')
    last_response.body.should.equal("This is plain text.\n")
  end

  it 'should be able to send named files with Content-Disposition' do
    get '/sub1/send_existing_file_named_attachment'
    last_response.status.should.equal(200)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.headers['Content-Disposition'].should.equal('attachment; filename="bazinga!.txt"')
    last_response.body.should.equal("This is plain text.\n")
  end

  it 'should respond with 404 when trying to send non-existing files' do
    get '/sub1/send_nonexisting_file'
    last_response.status.should.equal(404)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.headers.key?('Content-Disposition').should.equal(false)
    last_response.body.should.equal('Not Found')
  end

  it 'should be able to handle dynamic layouts and views' do
    get '/sub4/foo'
    last_response.status.should.equal(200)
    last_response.body.should.equal("LAYOUT: myfoo: FOO\n\n")
    get '/sub4/bar'
    last_response.status.should.equal(200)
    last_response.body.should.equal("LAYOUT: mybar: BAR\n\n")
    get '/sub4/baz'
    last_response.status.should.equal(200)
    last_response.body.should.equal("LAYOUT: default: BAZ\n\n")
  end

  it 'should handle changes to global settings' do
    settings = app.instance_variable_get(:@registry).application_settings
    settings.fetch(:my_custom_secret).should.equal(42)
    settings.store(:my_custom_secret, '9Lazy9')
    settings.fetch(:my_custom_secret).should.equal('9Lazy9')
    settings.delete(:my_custom_secret)
    settings.fetch(:my_custom_secret).should.equal(nil)
    settings.default_content_type.should.equal('text/html')
    settings.fetch(:default_content_type).should.equal('text/html')
    settings.default_content_type = 'text/plain'
    settings.default_content_type.should.equal('text/plain')
    settings.fetch(:default_content_type).should.equal('text/plain')
    settings.default_content_type = 'text/html'
    settings.default_content_type.should.equal('text/html')
    settings.fetch(:default_content_type).should.equal('text/html')
  end
end
