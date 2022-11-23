class ImportSession < ApplicationRecord
  enum status: [ :queued, :processing, :success, :partial, :error ]
  has_many :assets, -> { order(created_at: :asc) }, dependent: :destroy

  accepts_nested_attributes_for :assets
  validate :check_assets

  def check_assets
    self.not_allowed_count = 0
    
    self.assets.each do |asset|
      unless asset.valid?
        self.append_error({
          file: asset.filename,
          message: asset.errors.full_messages
        })
        self.not_allowed_count += 1
        asset.destroy
      end
    end

    # If no asset is valid, update the status to 'failed' immediately so in the
    # controller we won't trigger an analyze job (see controller).
    if self.not_allowed_count == self.assets.length
      self.status = :failed
      self.remark = "No asset was saved. Check details for more information."
    elsif self.not_allowed_count > 0
      self.remark = "#{not_allowed_count} assets were not saved. Check details 
      for more information."
    end
  end

  def append_error(error)
    if self.details[:errors].nil?
      self.details[:errors] = [error]
    else
      self.details[:errors] << error
    end
  end
end
