# == Schema Information
#
# Table name: demands
#
#  id           :integer         not null, primary key
#  blackmail_id :integer         not null
#  description  :string(255)
#  completed    :boolean         default(FALSE), not null
#  updated_at   :datetime
#

class Demand < ActiveRecord::Base
  belongs_to :blackmail
end
