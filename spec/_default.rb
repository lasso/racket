describe 'The default Racket test Application' do
  extend Rack::Test::Methods

  def app
    @app ||= Racket::Application.default
  end

  it 'has mapped controllers correctly' do
    routes_by_controller = actions_by_controller = nil
    routes = app.instance_eval do
      router.instance_eval do
        routes_by_controller = @routes_by_controller
        actions_by_controller = @actions_by_controller
      end
    end

    routes_by_controller[DefaultRootController].should.equal('/')
    routes_by_controller[DefaultSubController1].should.equal('/sub1')
    routes_by_controller[DefaultSubController2].should.equal('/sub2')
    routes_by_controller[DefaultSubController3].should.equal('/sub3')
    routes_by_controller[DefaultInheritedController].should.equal('/sub3/inherited')

    actions_by_controller[DefaultRootController].length.should.equal(3)
    actions_by_controller[DefaultRootController].include?(:index).should.equal(true)
    actions_by_controller[DefaultRootController].include?(:my_first_route).should.equal(true)
    actions_by_controller[DefaultRootController].include?(:my_second_route).should.equal(true)
    actions_by_controller[DefaultSubController1].length.should.equal(3)
    actions_by_controller[DefaultSubController1].include?(:route_to_root).should.equal(true)
    actions_by_controller[DefaultSubController1].include?(:route_to_nonexisting).should.equal(true)
    actions_by_controller[DefaultSubController2].length.should.equal(3)
    actions_by_controller[DefaultSubController2].include?(:index).should.equal(true)
    actions_by_controller[DefaultSubController2].include?(:current_action).should.equal(true)
    actions_by_controller[DefaultSubController2].include?(:current_params).should.equal(true)
    actions_by_controller[DefaultSubController3].should.equal([:index])
    actions_by_controller[DefaultInheritedController].should.equal([:index])
  end

  it 'should set rack variables correctly' do
    get '/sub2/current_action'
    last_response.status.should.equal(200)
    last_response.body.should.equal('current_action')

    get '/sub2/current_params/foo/bar/baz'
    last_response.status.should.equal(200)
    JSON.parse(last_response.body).should.equal(['foo', 'bar', 'baz'])
  end

  it 'returns the correct respnse when calling index action' do
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
    last_response.body.should.equal('404 Not found')

    get '/sub2/nonono'
    last_response.status.should.equal(404)
    last_response.body.should.equal('404 Not found')
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
    _logger = app.options[:logger]
    sio = StringIO.new
    app.options[:logger] = Logger.new(sio)
    app.inform_all('Informational message');
    sio.string.should.match(/Informational message/)
    app.options[:logger] = _logger
  end

  it 'should be able to log messages to developer' do
    _logger = app.options[:logger]
    _mode = app.options[:mode]
    sio = StringIO.new
    app.options[:logger] = Logger.new(sio)
    app.options[:mode] = :live
    app.inform_dev('Development message');
    sio.string.should.be.empty
    app.options[:mode] = :dev
    app.inform_dev('Hey, listen up!');
    sio.string.should.match(%r(Hey, listen up!))
    app.options[:mode] = _mode
    app.options[:logger] = _logger
  end
end