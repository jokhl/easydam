class Asset < ApplicationRecord
  include FileUploader::Attachment(:file)

  #enum color_tag: [ :red, :orange, :yellow, :green, :blue, :purple, :gray ]
  enum status: [ :active, :disabled, :trash ]
  
  belongs_to :import_session, optional: true
  has_many :roles, as: :resource

  counter_culture :import_session
  validate :check_mime_type

  ALLOWED_MIME_TYPES = [
    "image/jpeg",
    "image/png",
    "image/tiff"
  ]

  def check_mime_type
    unless self.file.nil?
      unless ALLOWED_MIME_TYPES.include?(self.mime_type)
        self.errors.add(:file, "type not supported (#{self.mime_type})")
      end
    end
  end

  def filename
    self.file_data["metadata"]["filename"]
  end

  def mime_type
    self.file_data["metadata"]["mime_type"]
  end
end
