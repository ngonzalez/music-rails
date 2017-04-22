class SrrdbLimitReachedError < StandardError ; end
class SrrdbNotFound < StandardError ; end

ImportWorker.class_eval do
  def srrdb_request url, &_
    request = Typhoeus::Request.new url, followlocation: true
    request.on_complete do |response|
      raise SrrdbNotFound.new if response.code != 200 || response.body.blank?
      raise SrrdbLimitReachedError.new response.body if response.body == "You've reached the daily limit."
      sleep 1
      yield response
    end
    request.run
  end
  def import_srrdb_sfv
    begin
      srrdb_request "http://www.srrdb.com/release/details/#{release.name}" do |response|
        release_name = Nokogiri::HTML(response.body).css('#release-name')[0]['value']
        sfv_files = Nokogiri::HTML(response.body).css('table.stored-files').css('a.storedFile').select{|item| item['href'].downcase =~ /.sfv/ }
        raise SrrdbNotFound.new if sfv_files.blank?
        sfv_files.each do |sfv_file|
          file_name = sfv_file['href'].split("/").each_with_object([]){ |item, array|
            array << item if item == release_name || array.include?(release_name)
          }.reject{|item| item == release_name }.join "/"
          file_name = URI.unescape file_name
          next if release.sfv_files.srrdb.detect{|sfv| sfv.file_name == file_name }
          srrdb_request "http://www.srrdb.com/download/file/#{release_name}/#{file_name}" do |response|
            f = Tempfile.new ; f.write(clear_text(response.body)) ; f.rewind
            release.sfv_files.srrdb.create! file: f, file_name: file_name
            f.unlink
          end
        end
      end
    rescue SrrdbNotFound => e
      release.details[:srrdb_sfv] = :error
      release.save!
      return
    end
  end
end

Release.class_eval do
  scope :without_m3u_file, -> {
    where "NOT EXISTS (
      SELECT 1 FROM #{M3uFile.table_name}
      WHERE #{M3uFile.table_name}.release_id = #{Release.table_name}.id
      AND #{M3uFile.table_name}.deleted_at IS NULL
    )"
  }
  scope :without_srrdb_sfv_file, -> {
    where "NOT EXISTS (
      SELECT 1 FROM #{SfvFile.table_name}
      WHERE #{SfvFile.table_name}.release_id = #{Release.table_name}.id
      AND #{SfvFile.table_name}.source = 'srrDB'
      AND #{SfvFile.table_name}.deleted_at IS NULL
    )"
  }
  scope :without_nfo_files, -> {
    where "NOT EXISTS (
      SELECT 1 FROM #{Image.table_name}
      WHERE #{Image.table_name}.release_id = #{Release.table_name}.id
      AND type = '#{NfoFile.name}'
      AND #{Image.table_name}.deleted_at IS NULL
    )"
  }
  scope :without_images, -> {
    where "NOT EXISTS (
      SELECT 1 FROM #{Image.table_name}
      WHERE #{Image.table_name}.release_id = #{Release.table_name}.id
      AND type = '#{Image.name}'
      AND #{Image.table_name}.deleted_at IS NULL
    )"
  }
  def missing_files
    track_names = tracks.map { |track| track.name.split("/").last.downcase }
    m3u_files.each_with_object([]) do |m3u_file, array|
      array << :empty_folder if m3u_file.files.empty?
      m3u_file.files.each do |file_name|
        array << file_name if track_names.exclude?(file_name.downcase)
      end
    end
  end
  def scene?
    return false if !self.name
    year = self.name.split("-").select{ |item| item.match(/(\d{4})/) }.last
    year = self.name.split("-").select{ |item| ['19xx','199x','20xx','200x'].include?(item.downcase) } if !year
    year && !name.ends_with?(year.to_s)
  end
end
