class SubController1 < Racket::Controller

  def index
    'SubController1::index'
  end

  def route_to_root
    r(RootController, :index)
  end

  def route_to_nonexisting
    r(InheritedController, :nonono, :with, :params)
  end

end
