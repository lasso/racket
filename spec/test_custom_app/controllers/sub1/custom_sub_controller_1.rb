class CustomSubController1 < Racket::Controller

  def index
    "#{self.class}::#{__method__}"
  end

  def route_to_root
    r(CustomRootController, :index)
  end

  def route_to_nonexisting
    r(CustomInheritedController, :nonono, :with, :params)
  end

end
