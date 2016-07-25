describe 'A default Racket test application' do
  extend Rack::Test::Methods

  def app
    @app ||= Racket::Application.default
  end

  it 'should report the correct version' do
    Racket.version.should.equal(Racket::Version.current)
  end

  it 'has mapped controllers correctly' do
    app.router.routes.length.should.equal(5)
    app.router.routes[DefaultRootController].should.equal('/')
    app.router.routes[DefaultSubController1].should.equal('/sub1')
    app.router.routes[DefaultSubController2].should.equal('/sub2')
    app.router.routes[DefaultSubController3].should.equal('/sub3')
    app.router.routes[DefaultInheritedController].should.equal('/sub3/inherited')

    app.router.action_cache.items[DefaultRootController].length.should.equal(5)
    app.router.action_cache.items[DefaultRootController].include?(:index).should.equal(true)
    app.router.action_cache.items[DefaultRootController].include?(:my_first_route)
       .should.equal(true)
    app.router.action_cache.items[DefaultRootController].include?(:my_second_route)
       .should.equal(true)
    app.router.action_cache.items[DefaultSubController1].length.should.equal(4)
    app.router.action_cache.items[DefaultSubController1].include?(:route_to_root).should.equal(true)
    app.router.action_cache.items[DefaultSubController1].include?(:route_to_nonexisting)
       .should.equal(true)
    app.router.action_cache.items[DefaultSubController2].length.should.equal(5)
    app.router.action_cache.items[DefaultSubController2].include?(:index).should.equal(true)
    app.router.action_cache.items[DefaultSubController2].include?(:current_action)
       .should.equal(true)
    app.router.action_cache.items[DefaultSubController2].include?(:current_params)
       .should.equal(true)
    app.router.action_cache.items[DefaultSubController3].should.equal([:index])
    app.router.action_cache.items[DefaultInheritedController].should.equal([:index])
  end

  it 'should set rack variables correctly' do
    get '/sub2/current_action'
    last_response.status.should.equal(200)
    last_response.body.should.equal('current_action')

    get '/sub2/current_params/foo/bar/baz'
    last_response.status.should.equal(200)
    JSON.parse(last_response.body).should.equal(%w(foo bar baz))
  end

  it 'should get the correct middleware' do
    middleware = app.settings.middleware
    middleware.length.should.equal(2)
    middleware[0].class.should.equal(Array)
    middleware[0].length.should.equal(2)
    middleware[0].first.should.equal(Rack::ContentType)
    middleware[1].class.should.equal(Array)
    middleware[1].length.should.equal(2)
    middleware[1].first.should.equal(Rack::Session::Cookie)
    true.should.equal(true)
  end

  it 'returns the correct response when calling index action' do
    # RootController
    get '/'
    last_response.status.should.equal(200)
    last_response.body.should.equal('DefaultRootController::index')

    # SubController1
    get '/sub1'
    last_response.status.should.equal(200)
    last_response.body.should.equal('DefaultSubController1::index')

    # SubController2
    get '/sub2'
    last_response.status.should.equal(200)
    last_response.body.should.equal('DefaultSubController2::index')

    # SubController3
    get '/sub3'
    last_response.status.should.equal(200)
    last_response.body.should.equal('DefaultSubController3::index')

    # InheritedController
    get '/sub3/inherited'
    last_response.status.should.equal(200)
    last_response.body.should.equal('DefaultInheritedController::index')
  end

  it 'should return 404 on calling nonexisting action' do
    get '/nonono'
    last_response.status.should.equal(404)
    last_response.body.should.equal('404 Not Found')

    get '/sub2/nonono'
    last_response.status.should.equal(404)
    last_response.body.should.equal('404 Not Found')
  end

  it 'should be able to find routes within the same controller' do
    get '/my_first_route'
    last_response.status.should.equal(200)
    last_response.body.should.equal('/my_second_route')

    get '/my_second_route'
    last_response.status.should.equal(200)
    last_response.body.should.equal('/my_first_route/with/params')
  end

  it 'should be able to find routes in other controllers' do
    get '/sub1/route_to_root'
    last_response.status.should.equal(200)
    last_response.body.should.equal('/index')

    get '/sub1/route_to_nonexisting'
    last_response.status.should.equal(200)
    last_response.body.should.equal('/sub3/inherited/nonono/with/params')
  end

  it 'should be able to log messages to everybody' do
    registry = app.registry
    original_logger = registry.application_logger
    sio = StringIO.new
    new_logger = Racket::Utils::Application::Logger.new(Logger.new(sio), :live)
    registry.forget(:application_logger)
    registry.singleton(:application_logger) { new_logger }
    app.inform_all('Informational message')
    sio.string.should.match(/Informational message/)
    registry.forget(:application_logger)
    registry.singleton(:application_logger) { original_logger }
  end

  it 'should be able to log messages to developer' do
    registry = app.registry
    original_logger = registry.application_logger
    sio = StringIO.new
    live_logger = Racket::Utils::Application::Logger.new(Logger.new(sio), :live)
    registry.forget(:application_logger)
    registry.singleton(:application_logger) { live_logger }
    app.inform_dev('Development message')
    sio.string.should.be.empty
    dev_logger = Racket::Utils::Application::Logger.new(Logger.new(sio), :dev)
    registry.forget(:application_logger)
    registry.singleton(:application_logger) { dev_logger }
    app.inform_dev('Hey, listen up!')
    sio.string.should.match(/Hey, listen up!/)
    registry.forget(:application_logger)
    registry.singleton(:application_logger) { original_logger }
  end

  it 'should be able to set and clear session variables' do
    get '/session_as_json'
    last_response.headers.keys.should.not.include('Set-Cookie')
    response = JSON.parse(last_response.body)
    response.class.should.equal(Hash)
    response.keys.should.be.empty
    get '/session_as_json?foo=bar'
    last_response.headers.keys.should.include('Set-Cookie')
    last_response.headers['Set-Cookie'].should.match(/racket.session=/)
    response = JSON.parse(last_response.body)
    response.class.should.equal(Hash)
    response.keys.length.should.equal(2)
    response.keys.should.include('foo')
    response.keys.should.include('session_id')
    get '/session_as_json?baz=quux'
    last_response.headers.keys.should.include('Set-Cookie')
    last_response.headers['Set-Cookie'].should.match(/racket.session=/)
    response = JSON.parse(last_response.body)
    response.class.should.equal(Hash)
    response.keys.length.should.equal(3)
    response.keys.should.include('foo')
    response.keys.should.include('baz')
    response.keys.should.include('session_id')
    get '/session_as_json?drop_session'
    last_response.headers.keys.should.include('Set-Cookie')
    last_response.headers['Set-Cookie'].should.match(/racket.session=/)
    response = JSON.parse(last_response.body)
    response.class.should.equal(Hash)
    response.keys.should.be.empty
    get '/session_strings'
    response = JSON.parse(last_response.body)
    response.length.should.equal(3)
    response.each { |elem| elem.should.match(/Racket::Session/) }
  end

  it 'should handle GET parameters correctly' do
    get '/sub2/some_get_data/?data1=foo&data3=bar'
    last_response.status.should.equal(200)
    response = JSON.parse(last_response.body, symbolize_names: true)
    response.class.should.equal(Hash)
    response.keys.sort.should.equal([:data1, :data2, :data3])
    response[:data1].should.equal('foo')
    response[:data2].should.equal(nil)
    response[:data3].should.equal('bar')
  end

  it 'should handle POST parameters correctly' do
    post '/sub2/some_post_data', data1: 'foo', data3: 'bar'
    last_response.status.should.equal(200)
    response = JSON.parse(last_response.body, symbolize_names: true)
    response.class.should.equal(Hash)
    response.keys.sort.should.equal([:data1, :data2, :data3])
    response[:data1].should.equal('foo')
    response[:data2].should.equal(nil)
    response[:data3].should.equal('bar')
  end

  it 'should be able to serve static files' do
    get '/hello.txt'
    last_response.status.should.equal(200)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.body.should.equal("Hello there\n")
  end

  it 'should handle exceptions correctly' do
    get '/sub1/epic_fail'
    last_response.status.should.equal(500)
    last_response.headers['Content-Type'].should.equal('text/plain')
    last_response.body.should.equal('500 Internal Server Error')
  end
end
