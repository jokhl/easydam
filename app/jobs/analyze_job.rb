class AnalyzeJob < ApplicationJob
  queue_as :default

  STEPS_PER_IMPORT_SESSION = 2

  attr_accessor :curr_step, :total_steps, :import_session

  def perform(record_class, record_id)
    if record_class == ImportSession.class.name
      perform_for_import_session(record_id)
    elsif record_class == Asset.class.name
      perform_for_asset(record_id)
    end
  end

  def perform_for_asset(asset_id)
    asset = Asset.find asset_id
    attacher = asset.file_attacher
    attacher.create_derivatives # manually create thumbnails
    metadata = get_metadata(attacher)
    attacher.file.add_metadata(metadata)
    attacher.write
    attacher.atomic_promote
  rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
    Rails.logger.error "Error"
  end

  def perform_for_import_session(import_session_id)
    import_session = ImportSession.find(import_session_id)
    import_session.update(status: :processing)
    self.import_session = import_session
    self.total_steps = import_session.assets_count * STEPS_PER_IMPORT_SESSION + 1
    self.curr_step = 0

    import_session.assets.each do |asset|
      attacher = asset.file_attacher
      send_progress("Generating thumbnails...")
      attacher.create_derivatives # manually create thumbnails
      send_progress("Fetching metadata...")
      metadata = get_metadata(attacher)
      attacher.file.add_metadata(metadata)
      attacher.write
      attacher.atomic_promote
    end
    
    if import_session.not_allowed_count > 0
      import_session.update(status: :partial)
    else
      import_session.update(status: :success)
    end

    send_progress("Import done.")
  rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
    import_session.update(status: :error)
    Rails.logger.error "Error"
  end
  
  def get_metadata(attacher)
    Rails.logger.debug "Mime-Type: #{attacher.file.mime_type}"

    case attacher.file.mime_type
    when "image/tiff"
      return analyze_image(attacher)
    when "image/jpeg"
      return analyze_image(attacher)
    else
      return {}
    end
  end

  def analyze_image(attacher)
    file = attacher.file
    exif_object = Exiftool.new(file.storage.path(file.id))
    exif = exif_object.to_hash

    metadata = {
      width: exif[:image_width],
      height: exif[:image_height],
      model: exif[:model],
      orientation: exif[:orientation],
      taken_on: exif[:create_date_civil],
      compression: exif[:compression],
      exposure: exif[:exposure_time],
      exposure_compensation: exif[:exposure_compensation],
      f_number: exif[:f_number],
      mode: exif[:exposure_program],
      iso: exif[:iso],
      focal_length: exif[:focal_length],
      flash: exif[:flash],
      white_balance: exif[:white_balance],
      focus_mode: exif[:focus_mode],
      color_space: exif[:color_space],
      vibration_reduction: exif[:vibration_reduction],
      picture_control_name: exif[:picture_control_name],
      lens: exif[:lens],
      all: exif
    }

    # Clean up undefined EXIF data
    metadata.delete_if {|key, value| value.nil? }

    return metadata
  end

  private

  def send_progress(msg, step = 1)
    self.curr_step += step
    data = {
      event: 'progress',
      payload: {
        import_session: {
          id: self.import_session.id,
          status: self.import_session.status,
          assets_count: self.import_session.assets_count,
          assets: self.import_session.assets,
          created_at: self.import_session.created_at
        },
        progress: ( self.curr_step.to_f / self.total_steps.to_f ),
        message: msg
      }
    }
    MessageBus.publish(
      "/import_sessions/#{self.import_session.id}",
      data.to_json
    )
  end
end
