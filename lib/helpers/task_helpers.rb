module TaskHelpers
  def update_release release
    if !File.directory? release.decorate.public_path
      FOLDERS.each do |folder|
        ALLOWED_SOURCES.each do |source|
          set_changes release, folder, source
        end
      end
      FOLDERS_WITH_SUBFOLDERS.each do |folder|
        subfolders(folder).each do |subfolder|
          ALLOWED_SOURCES.each do |source|
            set_changes release, folder, source, subfolder
          end
        end
      end
      release.destroy if !File.directory? release.decorate.public_path
    end
  end
  def set_changes release, folder, source, subfolder=nil
    if File.directory? [BASE_PATH, folder, subfolder, source, release.name].reject(&:blank?).join('/')
      release.update!(source: source) if release.read_attribute(:source) != source
      release.update!(folder: folder) if release.folder != folder
      release.update!(subfolder: subfolder) if release.subfolder != subfolder
    end
  end
  def subfolders folder
    Release.where(folder: folder).pluck(:subfolder).uniq
  end
  def import_folders
    items = Release.pluck :name
    FOLDERS.each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          name = path.split("/").last
          next if EXCEPT_RLS.include?(name) || items.include?(name)
          ImportWorker.new(path: path, name: name,
            folder: folder, source: source).perform
        end
      end
    end
  end
  def import_subfolders
    items = Release.pluck :name
    FOLDERS_WITH_SUBFOLDERS.each do |folder_path|
      Dir["#{BASE_PATH}/#{folder_path}/**"].each do |subfolder_path|
        ALLOWED_SOURCES.each do |source|
          Dir["#{subfolder_path}/#{source}/**"].each do |path|
            name = path.split("/").last
            subfolder = subfolder_path.split("/").last
            folder = subfolder_path.gsub("#{BASE_PATH}/", "").gsub("/#{subfolder}", "")
            next if EXCEPT_RLS.include?(name) || items.include?(name)
            ImportWorker.new(path: path, name: name,
              folder: folder, source: source, subfolder: subfolder).perform
          end
        end
      end
    end
  end
end