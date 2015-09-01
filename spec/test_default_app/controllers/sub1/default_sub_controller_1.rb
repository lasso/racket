# Default sub controller 1
class DefaultSubController1 < Racket::Controller
  def index
    "#{self.class}::#{__method__}"
  end

  def route_to_root
    r(DefaultRootController, :index)
  end

  def route_to_nonexisting
    r(DefaultInheritedController, :nonono, :with, :params)
  end

  def epic_fail
    fail 'Epic fail!'
  end
end
