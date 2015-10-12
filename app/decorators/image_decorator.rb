class ImageDecorator < Draper::Decorator
  delegate_all
  def thumb
    object.file.thumb("300x250>")
  end
  def thumb_high
    object.file.thumb("600x500>")
  end
end