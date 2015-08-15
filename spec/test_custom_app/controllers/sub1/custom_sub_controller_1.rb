class CustomSubController1 < Racket::Controller

  helper :file

  def index
    "#{self.class}::#{__method__}"
  end

  def route_to_root
    r(CustomRootController, :index)
  end

  def route_to_nonexisting
    r(CustomInheritedController, :nonono, :with, :params)
  end

  def epic_fail
    fail 'Epic fail!'
  end

  def send_existing_file_auto_mime
    send_file('files/plain_text.txt')
  end

  def send_existing_file_custom_mime
    send_file('files/plain_text.txt', mime_type: 'text/skv')
  end

  def send_existing_file_unnamed_attachment
    send_file('files/plain_text.txt', download: true)
  end

  def send_existing_file_named_attachment
    send_file('files/plain_text.txt', download: true, filename: 'bazinga!.txt')
  end

  def send_nonexisting_file
    send_file('files/no_such_thing.jpg')
  end

end
