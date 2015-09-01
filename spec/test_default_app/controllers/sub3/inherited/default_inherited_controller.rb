require_relative '../default_sub_controller_3.rb'

# Default inherited controller
class DefaultInheritedController < DefaultSubController3
  def index
    "#{self.class}::#{__method__}"
  end
end
