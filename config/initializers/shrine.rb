require "shrine/storage/file_system"

Shrine.plugin :activerecord
Shrine.plugin :instrumentation
Shrine.plugin :determine_mime_type, analyzer: :marcel
Shrine.plugin :add_metadata
Shrine.plugin :backgrounding
Shrine.plugin :derivatives,
  create_on_promote:      false, # do not create thumbnails on promotion (= save)
  versions_compatibility: true  # handle versions column format
Shrine.plugin :store_dimensions

# Global background jobs

Shrine::Attacher.destroy_block do
  DestroyJob.perform_later(self.class.name, data)
end

# Storages

Shrine.storages = { 
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
}
