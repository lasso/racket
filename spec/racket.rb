require 'simplecov'
require 'stringio'

SimpleCov.start do
  add_filter 'spec/test_app'
end

TEST_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_app'))

Dir.chdir(TEST_APP_DIR) do
  require 'racket'
  require 'rack/test'
  require 'bacon'

  describe 'The Racket Test Application' do
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

      routes_by_controller[RootController].should.equal('/')
      routes_by_controller[SubController1].should.equal('/sub1')
      routes_by_controller[SubController2].should.equal('/sub2')
      routes_by_controller[SubController3].should.equal('/sub3')
      routes_by_controller[InheritedController].should.equal('/sub3/inherited')

      actions_by_controller[RootController].length.should.equal(3)
      actions_by_controller[RootController].include?(:index).should.equal(true)
      actions_by_controller[RootController].include?(:my_first_route).should.equal(true)
      actions_by_controller[RootController].include?(:my_second_route).should.equal(true)
      actions_by_controller[SubController1].length.should.equal(3)
      actions_by_controller[SubController1].include?(:route_to_root).should.equal(true)
      actions_by_controller[SubController1].include?(:route_to_nonexisting).should.equal(true)
      actions_by_controller[SubController2].length.should.equal(3)
      actions_by_controller[SubController2].include?(:index).should.equal(true)
      actions_by_controller[SubController2].include?(:current_action).should.equal(true)
      actions_by_controller[SubController2].include?(:current_params).should.equal(true)
      actions_by_controller[SubController3].should.equal([:index])
      actions_by_controller[InheritedController].should.equal([:index])
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
      last_response.body.should.equal('RootController::index')

      # SubController1
      get '/sub1'
      last_response.status.should.equal(200)
      last_response.body.should.equal('SubController1::index')

      # SubController2
      get '/sub2'
      last_response.status.should.equal(200)
      last_response.body.should.equal('SubController2::index')

      # SubController3
      get '/sub3'
      last_response.status.should.equal(200)
      last_response.body.should.equal('SubController3::index')

      # InheritedController
      get '/sub3/inherited'
      last_response.status.should.equal(200)
      last_response.body.should.equal('InheritedController::index')
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

    it 'should be able to log messages' do
      _logger = app.options[:logger]
      sio = StringIO.new
      app.options[:logger] = Logger.new(sio)
      app.inform_all('Informational message');
      sio.string.index('Informational message').should.equal(49)
      app.options[:logger] = _logger
    end

  end
end
