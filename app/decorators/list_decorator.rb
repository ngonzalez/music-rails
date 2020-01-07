class ListDecorator < Draper::Decorator
  def file_names
    files = File.read(file.path).split("\n")
    files = files.reject { |line| line =~ /^#|^;/ }.reject(&:blank?)
    files = files.grep(/#{ALLOWED_AUDIO_FORMATS.flat_map { |_, format| format[:extensions] }.join("|")}/)
    files = files.map(&:strip).collect { |line| line.split(' ')[0] }
    files
  end
end
