describe 'Racket::Utils::Vievs::TemplateCache should adhere to Moneta::Cache interface' do
  templates = {
      :template_1 => nil,
      :template_2 => 'template.haml',
      :template_3 => :template,
      :template_4 => ->(action) { action.to_s }
  }.freeze

  describe 'API compliance' do
    cache = Racket::Utils::Views::TemplateCache.new({})
    it 'should respond to all methods in the Moneta API' do
      [:[], :load, :fetch, :[]=, :store, :delete, :key?, :increment, :decrement, :create, :clear,
       :close, :features, :supports?].each do |meth|
        cache.should.respond_to?(meth)
      end
    end

    it 'should raise NotImplementedError on call to create' do
      cache.supports?(:create).should.equal(false)
      -> { cache.create('foo', 'bar') }
        .should.raise(NotImplementedError)
    end

    it 'should raise NotImplementedError on call to decrement' do
      cache.supports?(:decrement).should.equal(false)
      -> { cache.decrement('foo') }
        .should.raise(NotImplementedError)
    end

    it 'should raise NotImplementedError on call to increment' do
      cache.supports?(:increment).should.equal(false)
      -> { cache.increment('foo') }
        .should.raise(NotImplementedError)
    end

    it 'should return an empty list of features' do
      cache.features.length.should.equal(0)
    end
  end

  describe 'Cache without default expiration' do
    it 'should not expire items set with []= by default' do
      cache = Racket::Utils::Views::TemplateCache.new({})
      templates.each_pair do |key, val|
        cache[key] = val
      end
      sleep(2)
      templates.each_pair do |key, val|
        cache[key].should.equal(val)
      end
    end
    it 'should not expire items set with store by default' do
      cache = Racket::Utils::Views::TemplateCache.new({})
      templates.each_pair do |key, val|
        cache.store(key, val)
      end
      sleep(2)
      templates.each_pair do |key, val|
        cache.fetch(key).should.equal(val)
      end
    end
    it 'should expire items set with store and an explicit expire time' do
      cache = Racket::Utils::Views::TemplateCache.new({})
      templates.each_pair do |key, val|
        cache.store(key, val, expires: 3)
      end
      sleep(2)
      templates.each_pair do |key, val|
        cache.fetch(key).should.equal(val)
      end
      templates.each_pair do |key, val|
        cache.fetch(key, :foobar).should.equal(val)
      end
      templates.each_pair do |key, val|
        cache.fetch(key) { 'out of space' }.should.equal(val)
      end
      sleep(2)
      templates.each_key do |key|
        cache.fetch(key).should.equal(nil)
      end
      templates.each_key do |key|
        cache.fetch(key, :foobar).should.equal(:foobar)
      end
      templates.each_key do |key|
        cache.fetch(key) { 'out of space' }.should.equal('out of space')
      end
    end
    it 'should handle deletes correctly' do
      cache = Racket::Utils::Views::TemplateCache.new({})
      cache['number'] = 'one'
      cache['number'].should.equal('one')
      cache.delete('number')
      cache['number'].should.equal(nil)
      cache['number'] = 'two'
      cache['number'].should.equal('two')
      cache.clear
      cache['number'].should.equal(nil)
      cache['number'] = 'three'
      cache['number'].should.equal('three')
      cache.close
      cache['number'].should.equal(nil)
    end
  end

  describe 'Cache with default expiration' do
    it 'should expire items set with []= by default' do
      cache = Racket::Utils::Views::TemplateCache.new(expires: 3)
      templates.each_pair do |key, val|
        cache[key] = val
      end
      sleep(2)
      templates.each_pair do |key, val|
        cache[key].should.equal(val)
      end
      sleep(2)
      templates.each_key do |key|
        cache[key].should.equal(nil)
      end
    end
    it 'should expire items set with store by default' do
      cache = Racket::Utils::Views::TemplateCache.new(expires: 3)
      templates.each_pair do |key, val|
        cache.store(key, val)
      end
      sleep(2)
      templates.each_pair do |key, val|
        cache.fetch(key).should.equal(val)
      end
      sleep(2)
      templates.each_key do |key|
        cache.fetch(key).should.equal(nil)
      end
    end
    it 'should not expire items set with a longer expire time' do
      cache = Racket::Utils::Views::TemplateCache.new(expires: 3)
      templates.each_pair do |key, val|
        cache.store(key, val, expires: 5)
      end
      sleep(4)
      templates.each_pair do |key, val|
        cache.fetch(key).should.equal(val)
      end
      templates.each_pair do |key, val|
        cache.fetch(key, :foobar).should.equal(val)
      end
      templates.each_pair do |key, val|
        cache.fetch(key) { 'out of space' }.should.equal(val)
      end
      sleep(2)
      templates.each_key do |key|
        cache.fetch(key).should.equal(nil)
      end
      templates.each_key do |key|
        cache.fetch(key, :foobar).should.equal(:foobar)
      end
      templates.each_key do |key|
        cache.fetch(key) { 'out of space' }.should.equal('out of space')
      end
    end
    it 'should handle deletes correctly' do
      cache = Racket::Utils::Views::TemplateCache.new(expires: 60)
      cache['number'] = 'one'
      cache['number'].should.equal('one')
      cache.delete('number')
      cache['number'].should.equal(nil)
      cache['number'] = 'two'
      cache['number'].should.equal('two')
      cache.clear
      cache['number'].should.equal(nil)
      cache['number'] = 'three'
      cache['number'].should.equal('three')
      cache.close
      cache['number'].should.equal(nil)
    end
  end
end
