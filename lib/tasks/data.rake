namespace :data do
  desc 'Index data'
  task index: :environment do
    [MusicFolder, AudioFile].each do |class_name|
      class_name.find_each &:index
    end
    Sunspot.commit
  end
end
