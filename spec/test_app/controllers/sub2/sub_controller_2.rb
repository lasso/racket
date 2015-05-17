class SubController2 < Racket::Controller

  def index
    'SubController2::index'
  end

  def current_action
    request.action
  end

  def current_params
    request.params.to_json
  end

end
