# == Schema Information
#
# Table name: demands
#
#  id         	:integer        not null, primary key
#  description  :string(255)
#  completed    :boolean		not null, default set to false
#  created_at 	:datetime		not null
#  updated_at 	:datetime		not null
#

class Demand < ActiveRecord::Base
  belongs_to :blackmail

  # Validations
  validates :completed,  :presence => true
end
