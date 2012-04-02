# == Schema Information
#
# Table name: users
#
#  id         		:integer      	not null, primary key
#  email      		:string(255)	
#  password_digest 	:string			not null
#  created_at 		:datetime		not null
#  updated_at 		:datetime		not null
#

class User < ActiveRecord::Base
  # Relations
  has_many :blackmails, dependent: :delete_all
  
  # Validations
  # email must not be blank, and must follow the email format
  validates :email, email: true
  has_secure_password
  
end