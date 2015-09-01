require 'json'

# Default root controller
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
    request.get_params.each_pair do |key, value|
      if key == 'drop_session'
        session.clear
      else
        session[key] = value
      end
    end
    session.to_hash.to_json
  end

  def session_strings
    [session.inspect, session.to_s, session.to_str].to_json
  end
end
