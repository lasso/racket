# Custom sub controller 2
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

  def hook_action
    @action = 'Data added in action'
    [@before, @action].to_json
  end

  before do
    @before = 'Data added in before block'
  end

  after :hook_action do
    response.headers['X-Hook-Action'] = 'run'
  end

  helper :nonexisting
end
