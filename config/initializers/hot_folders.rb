#require "rb-fsevent"
#
#paths = ["/Users/mokh/Downloads/Hot Folder"]
#
#fsevent = FSEvent.new
#fsevent.watch paths do |paths, event_meta|
#  event_meta['events'].each do |event|
#    puts "event ID: #{event['id']}"
#    puts "path: #{event['path']}"
#    puts "c flags: #{event['cflags']}"
#    puts "named flags: #{event['flags'].join(', ')}"
#    # named flags will include strings such as `ItemInodeMetaMod` or `OwnEvent`
#  end
#end
#fsevent.run
