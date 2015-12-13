describe 'A custom Racket test application' do
  extend Rack::Test::Methods
  def app
    @app ||= Racket::Application.using(
      default_layout: 'zebra.*',
      logger: nil,
      my_custom_secret: 42,
      mode: :dev,
      view_dir: 'templates'
    )
  end

  it 'should set requested settings' do
    app.settings.default_layout.should.equal('zebra.*')
    app.settings.view_dir.should.equal(Racket::Utils.build_path('templates'))
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
    app.settings.fetch(:my_custom_secret).should.equal(42)
    app.settings.store(:my_custom_secret, '9Lazy9')
    app.settings.fetch(:my_custom_secret).should.equal('9Lazy9')
    app.settings.delete(:my_custom_secret)
    app.settings.fetch(:my_custom_secret).should.equal(nil)
    app.settings.default_content_type.should.equal('text/html')
    app.settings.fetch(:default_content_type).should.equal('text/html')
    app.settings.default_content_type = 'text/plain'
    app.settings.default_content_type.should.equal('text/plain')
    app.settings.fetch(:default_content_type).should.equal('text/plain')
    app.settings.default_content_type = 'text/html'
    app.settings.default_content_type.should.equal('text/html')
    app.settings.fetch(:default_content_type).should.equal('text/html')
  end
end
