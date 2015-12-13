class MainController < Racket::Controller
  helper :sass

  def css_path
    css(:foo)
  end
end
