class M3uFileDecorator < Draper::Decorator
  delegate_all
  def file_names
    File.read(file.path).split("\n").reject{ |line| line =~ /^#/ }.reject(&:blank?).grep(/#{ALLOWED_AUDIO_FORMATS.join("|")}/).map(&:strip)
  end
end