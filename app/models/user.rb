# == Schema Information
#
# Table name: users
#
#  id         :integer      not null, primary key
#  email      :string(255)	not null
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  # Relations
  has_many :blackmails, dependent: :destroy
  
  # Validations
  #email must not be blank, and must follow the email format
  validates :email, :presence   => true, email: true
  has_secure_password #only available in Rails 3.1+, see rails3tutorial section 13.3

end
