# Custom sub controller 3
class CustomSubController3 < Racket::Controller
  setting(:top_secret, 42)

  def index
    "#{self.class}::#{__method__}"
  end

  def a_secret_place
    redirect(rs(__method__, settings.fetch(:top_secret)))
  end

  def not_so_secret
    redirect!(rs(__method__, 21))
  end

  after :not_so_secret do
    raise 'Should not happen!'
  end

  def render_a_file
    obj = Object.new
    obj.instance_eval { @secret = 42 }
    render_template('files/secret.erb', obj)
  end

  def render_a_file_with_controller
    @one = 1
    @two = 2
    @three = 3
    render_template('files/triplet.erb', self)
  end
  
  def render_a_file_with_settings
    obj = Object.new
    obj.instance_eval do
      @one = 1
      @two = 2
      @three = 3
    end
    settings = { trim: '-' }
    render_template('files/triplet.erb', obj, settings)
  end
end
