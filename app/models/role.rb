class Role < ApplicationRecord
  belongs_to :resource, polymorphic: true, optional: true
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :name, presence: true
  validates :permissions, presence: true

  def has_permission?(permission)
    self.permissions[permission] || false
  end
end
