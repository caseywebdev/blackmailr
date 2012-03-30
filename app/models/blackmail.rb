# == Schema Information
#
# Table name: blackmails
#
#  id         	:integer    	not null, primary key
#  title       	:string(255)
#  description       :string(255)
#  victim_name       :string(255)
#  victim_email      :string(255)	not null
#  expired_at 	:datetime
#  created_at 	:datetime
#  updated_at 	:datetime
#  :user is referenced		not null
#

class Blackmail < ActiveRecord::Base
  # Relations  
  belongs_to :user
  has_many :demands, dependent: :delete_all
  
  # Validations
  validates :victim_email, email: true
end
