class CustomSubController3 < Racket::Controller

  set_option(:top_secret, 42)

  def index
    "#{self.class}::#{__method__}"
  end

  def a_secret_place
    redirect(rs(__method__, self.class.get_option(:top_secret)))
  end

end
