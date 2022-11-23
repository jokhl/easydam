namespace :samples do
  desc "TODO"
  task import: :environment do
    path = "/Users/mokh/Downloads/train"
    Dir.foreach(path) do |filename|
      next if filename == '.' || filename == '..'

      puts "Importing #{filename}..."
      file = File.open("#{path}/#{filename}", 'r')

      asset = Asset.new file: file
      if asset.valid?
        asset.file_derivatives!
        asset.save
      else
        puts asset.errors.full_messages
      end

      file.close
    end
  end

  task assign_tags: :environment do
    total = Asset.count

    for i in 1..2000
      id = rand(0..total)
      asset = Asset.find_by id: id
      unless asset.nil?
        asset.set_tag_list_on(:booba, "menfin")
        asset.save
        asset.reindex
        puts "Updated asset##{asset.id}"
      end
    end
  end

end
