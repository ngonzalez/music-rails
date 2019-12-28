class SfvFileDecorator < ListDecorator
  delegate_all

  def check
    case Dir.chdir([release.decorate.public_path, sfv_file.base_path].join('/')) { %x[cfv -f #{sfv_file.file.path}] }
      when /#{file_names.length} files, #{file_names.length} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end
end
