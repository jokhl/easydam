class User < ApplicationRecord
  acts_as_authentic do |c|
    c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
  end

  has_many :user_roles
  has_many :roles, through: :user_roles

  validates :email,
    format: {
      with: /@/,
      message: "should look like an email address."
    },
    length: { maximum: 100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_email?
    }

  validates :login,
    format: {
      with: /\A[a-z0-9]+\z/,
      message: "should use only letters and numbers."
    },
    length: { within: 3..100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_login?
    }

  validates :password,
    confirmation: { if: :require_password? }
    #length: {
    #  minimum: 8,
    #  if: :require_password?
    #}
    
  #validates :password_confirmation,
    #length: {
    #  minimum: 8,
    #  if: :require_password?
    #}

  def has_role?(role, resource = nil)
    self.roles.where({ name: role, resource: resource }.compact).exists?
  end

  def add_role(role, resource = nil)
    role = Role.find_or_create_by!({ name: role, resource: resource }.compact)
    self.roles << role
  end
end
