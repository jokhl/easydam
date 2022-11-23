class Property < ApplicationRecord
  before_save :set_key

  validates :name,
    presence: true,
    format: {
      with: /\A[\w\s]+\z/,
      message: "only allows letters, digits, underscore or space"
    }

  private

  def set_key
    self.key = self.name.parameterize.underscore
  end
end
