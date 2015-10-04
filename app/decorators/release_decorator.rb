class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [BASE_URL, self.folder, self.name].join("/")
  end
end