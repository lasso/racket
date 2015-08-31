class DefaultSubController3 < Racket::Controller
  def index
    "#{self.class}::#{__method__}"
  end

  protected

  def protected_method
    "I'm protected"
  end

  private

  def private_method
    "I'm private"
  end
end
