namespace "data" do

  require Rails.root.join "lib/task_helpers"
  include TaskHelpers

  desc "update data"
  task update: :environment do
    ["clear_data", "load_data", "set_details"].each do |name|
      Rake::Task["data:#{name}"].execute
    end
  end

  desc "clear data"
  task clear_data: :environment do
    Release.find_each do |release|
      if !File.directory? release.decorate.public_path
        release.destroy
      end
    end
  end

  desc "load data"
  task load_data: :environment do
    require 'progress_bar'
    bar = ProgressBar.new Release.count

    ["dnb","hc","other","backup2"].each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          ImportWorker.new.perform name: path.split("/").last, folder: folder, path: path, source: source
          bar.increment!
        end
      end
    end

    Dir["#{BASE_PATH}/backup/**"].each do |label_path|
      label_name = label_path.split("/").last
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/backup/#{label_name}/#{source}/**"].each do |path|
          ImportWorker.new.perform name: path.split("/").last, folder: "backup", path: path, source: source, label_name: label_name
          bar.increment!
        end
      end
    end
  end

  desc "set details"
  task set_details: :environment do
    release_set_details
  end

end
