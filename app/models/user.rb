class User < ActiveRecord::Base
  # Relations
  has_many :blackmails, dependent: :destroy
  
  # Validations
  validates :email, email: true
  has_secure_password
end
