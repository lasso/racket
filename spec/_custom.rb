describe 'A custom Racket test Application' do
  extend Rack::Test::Methods
  def app
    @app ||= Racket::Application.using(
      { default_layout: 'zebra.*', logger: nil, mode: :dev, view_dir: 'templates' },
      true
    )
  end

  it 'should set requested options' do
    app.options[:default_layout].should.equal('zebra.*')
    app.options[:view_dir].should.equal(Racket::Utils.build_path('templates'))
  end

  it 'should be able to get/set options on controller' do
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
    response.should.equal(["Data added in before block", "Data added in action"])
  end

  it 'should let Rack::ShowExceptions handle the error' do
    get '/sub1/epic_fail'
    last_response.status.should.equal(500)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.body.should.match(%r(^RuntimeError: Epic fail!))
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
    last_response.body.should.equal("Not Found")
  end
end
