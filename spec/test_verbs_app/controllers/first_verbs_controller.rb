# First verbs controller
class FirstVerbsController < Racket::Controller

  def getMe
    'GET successful'
  end

  def deleteMe
    'DELETE successful'
  end

  def headMe
    'HEAD successful'
  end

  def optionsMe
    'OPTIONS successful'
  end

  def postMe
    'POST successful'
  end

  def putMe
    "PUT successful"
  end

  allow(:post, :postMe)

end
