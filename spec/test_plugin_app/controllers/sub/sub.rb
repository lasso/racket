class SubController < Racket::Controller
  helper :sass

  def css_path
    css(:bar)
  end
end
