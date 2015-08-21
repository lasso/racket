describe 'Racket::Request should override Rack::Request correctly' do

  r = Racket::Request.new({}).freeze

  describe 'Racket::Request should inherit some methods from Rack::Request' do
    [
      :accept_encoding, :accept_language, :base_url, :body, :content_charset, :content_length,
      :content_type, :cookies, :delete?, :env, :form_data?, :fullpath, :get?, :head?, :host,
      :host_with_port, :ip, :link?, :logger, :media_type, :media_type_params, :options?,
      :parseable_data?, :patch?, :path, :path_info, :path_info=, :port, :post?, :put?,
      :query_string, :referer, :referrer, :request_method, :scheme, :script_name, :script_name=,
      :ssl?, :trace?, :trusted_proxy?, :unlink?, :url, :user_agent, :values_at, :xhr?
    ].each do |meth|
      it "should inherit #{meth} from Rack::Request" do
        r.respond_to?(meth).should.equal(true)
      end
    end
  end

  describe 'Racket::Request should not inherit methods that use merged GET and POST data' do
    [:[], :[]=, :delete_param, :params, :update_param].each do |meth|
      it "should not inherit #{meth} from Rack::Request" do
        r.respond_to?(meth).should.equal(false)
      end
    end
  end

  describe 'Racket::Request should not inherit session methods' do
    [:session, :session_options].each do |meth|
      it "should not inherit #{meth} from Rack::Request" do
        r.respond_to?(meth).should.equal(false)
      end
    end
  end

  describe 'Racket::Request should redefine methods for handling GET/POST data' do
    [:get_params, :post_params].each do |meth|
      it "should define #{meth}" do
        r.respond_to?(meth).should.equal(true)
      end
    end
    [:GET, :POST].each do |meth|
      it "should not define #{meth}" do
        r.respond_to?(meth).should.equal(false)
      end
    end
  end

end
