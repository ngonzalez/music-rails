module LocalFile
  extend ActiveSupport::Concern
  included do

    scope :local, -> { where(source: nil) }

    scope :srrdb, -> { where(source: 'srrDB') }

    def base_path
      file_name.split('/')[0] if file_name.split('/').length > 1
    end

    def file_exists?
      File.exists? file.path
    rescue
      false
    end

    def file_path
      [release.decorate.public_path, base_path].join '/'
    end
  end
end