require_relative '../default_sub_controller_3.rb'

class DefaultInheritedController < DefaultSubController3
  def index
    "#{self.class}::#{__method__}"
  end
end
