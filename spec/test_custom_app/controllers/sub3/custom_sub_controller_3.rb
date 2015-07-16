class CustomSubController3 < Racket::Controller

  set_option(:top_secret, 42)

  def index
    "#{self.class}::#{__method__}"
  end

  def a_secret_place
    redirect(rs(__method__, controller_option(:top_secret)))
  end

  def not_so_secret
    redirect!(rs(__method__, 21))
  end

  after :not_so_secret do
    fail 'Should not happen!'
  end

end
