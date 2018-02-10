module SfvHelpers
  def unchecked_releases(source=nil)
    if source && source == :srrdb
      Release.joins(:sfv_files).merge(SfvFile.srrdb).where(srrdb_last_verified_at: nil).select { |release| !release.details.has_key?(:srrdb_sfv) }
    else
      Release.joins(:sfv_files).merge(SfvFile.local).where(last_verified_at: nil).select { |release| !release.details.has_key?(:sfv) }
    end
  end
  def run_check_sfv release, sfv_file
    m3u_file = find_m3u release, sfv_file
    return :failed if !m3u_file
    files_count = m3u_file.decorate.file_names.length
    case Dir.chdir([release.decorate.public_path, sfv_file.base_path].join('/')) { %x[cfv -f #{sfv_file.file.path}] }
      when /#{files_count} files, #{files_count} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end
  def find_m3u release, sfv_file
    m3u_file = release.m3u_files.local.select { |item| item.file_name =~ /^0{2,3}/ }.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) }
    m3u_file = release.m3u_files.local.select { |item| item.file_name =~ /0{2,3}/  }.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) } if !m3u_file
    m3u_file = release.m3u_files.local.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) } if !m3u_file
    return m3u_file
  end
  def check_sfv release, source=nil
    key = source ? "#{source.downcase}_sfv".to_sym : :sfv
    field_name = source ? "#{source.downcase}_last_verified_at".to_sym : :last_verified_at
    return if release.send(field_name) || release.details[key]
    results = release.sfv_files.where(source: source).each_with_object([]){ |sfv_file, array| array << run_check_sfv(release, sfv_file) }
    if results.all? { |result| result == :ok }
      release.details.delete(key) if release.details.has_key?(key)
      release.update!(field_name => Time.now) if !release.send(field_name)
    else
      release.details[key] = results
      release.save!
    end
  end
end