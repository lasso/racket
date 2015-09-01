# Default sub controller 2
class DefaultSubController2 < Racket::Controller
  def index
    "#{self.class}::#{__method__}"
  end

  def current_action
    racket.action
  end

  def current_params
    racket.params.to_json
  end

  def some_get_data
    data = {}
    [:data1, :data2, :data3].each do |d|
      data[d] = request.get(d)
    end
    data.to_json
  end

  def some_post_data
    data = {}
    [:data1, :data2, :data3].each do |d|
      data[d] = request.post(d)
    end
    data.to_json
  end
end
