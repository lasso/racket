# Custom sub controller 4
class CustomSubController5 < Racket::Controller
  template_setting :trim, '>'

  def text
    @text = 'Hello World!'
  end
end
