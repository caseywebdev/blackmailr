class Blackmail < ActiveRecord::Base
  # Relations  
  belongs_to :user
  has_many :demands, dependent: :destroy
  
  # Validations
  validates :victim_email, email: true
end
