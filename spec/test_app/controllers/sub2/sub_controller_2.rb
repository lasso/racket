class SubController2 < Racket::Controller

  def index
    'SubController2::index'
  end

  def current_action
    racket.action
  end

  def current_params
    racket.params.to_json
  end

end
