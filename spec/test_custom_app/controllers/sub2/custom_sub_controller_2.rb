class CustomSubController2 < Racket::Controller

  def index
    "#{self.class}::#{__method__}"
  end

  def current_action
    racket.action
  end

  def current_params
    racket.params.to_json
  end

  def template
    @message = 'Message from template'
  end

end
