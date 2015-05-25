class DefaultSubController3 < Racket::Controller

  def index
    "#{self.class}::#{__method__}"
  end

end
