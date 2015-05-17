require_relative '../sub_controller_3.rb'

class InheritedController < SubController3

  def index
    'InheritedController::index'
  end

end
