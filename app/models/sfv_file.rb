class SfvFile < ActiveRecord::Base
  belongs_to :release

  has_paper_trail

  acts_as_paranoid

  dragonfly_accessor :file do
    storage_options {|a| { path: "sfv/%s" % [ UUID.new.generate ] } }
  end

  def check
    items = file_name.split("/") ; i = 0
    file_path = ([release.decorate.public_path] + items.each_with_object([]){|item, array| i += 1 ; array << item if i < items.length }).join "/"
    count = Dir.chdir(file_path) { %x[ls *.{#{ALLOWED_AUDIO_FORMATS.join(",")}} 2>/dev/null | wc -l] }.to_i
    case Dir.chdir(file_path) { %x[#{SFV_CHECK_APP} -f #{file.path}] }
      when /#{count} files, #{count} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end

end