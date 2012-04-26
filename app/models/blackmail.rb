# == Schema Information
#
# Table name: blackmail
#
#  id           :integer         not null, primary key
#  user_id      :integer         not null
#  title        :string(255)     not null
#  description  :string(255)     not null
#  victim_name  :string(255)     not null
#  victim_email :string(255)     not null
#  expired_at   :datetime
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  victim_token :string(255)
#

class Blackmail < ActiveRecord::Base
  
  scope :exposed, lambda {
    where(
      "( 
        SELECT COUNT(*)
        FROM demands
        WHERE blackmail_id = blackmail.id
        AND completed = :true
      ) < (
        SELECT COUNT(*)
        FROM demands
        WHERE blackmail_id = blackmail.id
      ) AND expired_at <= :now",
        true: true,
        now: 10.minutes.from_now
    ).order('expired_at DESC')
  }
  
  # Relations  
  belongs_to :user
  has_many :demands, dependent: :delete_all
  has_many :messages, dependent: :delete_all
  
  # Validations
  validates :victim_email, email: true
  validate :at_least_one_demand
  
  accepts_nested_attributes_for :demands

  # Concat demands
  def concat_demands
    demands.collect { |d| d.description }.join "\n"
  end
  
  def victim_view_url
    "http://blackmailr.herokuapp.com/view/#{id}?victim_token=#{victim_token}"
  end
  
  def image= uploaded_file
    self[:image] = uploaded_file.kind_of?(ActionDispatch::Http::UploadedFile) ? uploaded_file.read : uploaded_file
  end
  
  private
  
  def at_least_one_demand
    unless demands.any?
      errors.add :base, 'You must specify at least one demand.'
    end
  end
    
end
