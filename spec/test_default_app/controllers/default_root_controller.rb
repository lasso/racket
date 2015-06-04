require 'json'

class DefaultRootController < Racket::Controller

  def index
    "#{self.class}::#{__method__}"
  end

  def my_first_route
    rs(:my_second_route)
  end

  def my_second_route
    rs(:my_first_route, :with, 'params')
  end

  def session_as_json
    request.GET.each_pair do |key, value|
      if key == 'drop_session'
        request.session.clear
      else
        request.session[key] = value
      end
    end
    request.session.to_hash.to_json
  end

end
