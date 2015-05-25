require_relative '../custom_sub_controller_3.rb'

class CustomInheritedController < CustomSubController3

  def index
    "#{self.class}::#{__method__}"
  end

end
