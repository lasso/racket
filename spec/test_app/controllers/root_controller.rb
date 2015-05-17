class RootController < Racket::Controller

  def index
    'RootController::index'
  end

  def my_first_route
    rs(:my_second_route)
  end

  def my_second_route
    rs(:my_first_route, :with, 'params')
  end

end
