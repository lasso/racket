# Custom sub controller 4
class CustomSubController4 < Racket::Controller
  setting :default_layout, -> { 'layout.erb' }

  setting :default_view,
          lambda { |action|
            case action
            when :foo then 'myfoo.erb'
            when :bar then 'mybar.erb'
            else 'default.erb'
            end
          }

  def foo
    @data = 'FOO'
  end

  def bar
    @data = 'BAR'
  end

  def baz
    @data = 'BAZ'
  end
end
