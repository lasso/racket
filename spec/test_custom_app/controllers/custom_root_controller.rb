class CustomRootController < Racket::Controller

  def index
    "#{self.class}::#{__method__}"
  end

  def my_first_route
    rs(:my_second_route)
  end

  def my_second_route
    rs(:my_first_route, :with, 'params')
  end

end
