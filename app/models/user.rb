# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  email           :string(255)
#  password_digest :string(255)     not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  remember_token  :string(255)
#

class User < ActiveRecord::Base
  # Relations
  has_many :blackmail, dependent: :delete_all
  
  # Validations
  # email must not be blank, and must follow the email format
  validates :email, email: true, uniqueness: true
  has_secure_password
  
  before_save :create_remember_token
  
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
