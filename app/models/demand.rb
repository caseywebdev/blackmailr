# == Schema Information
#
# Table name: demands
#
#  id         	:integer         	not null, primary key
#  description    	:string(255)
#  completed      	:boolean		not null
#  created_at 	:datetime
#  updated_at 	:datetime
#

class Demand < ActiveRecord::Base
  belongs_to :blackmail

  # Validations
  validates :completed,  :presence => true
end
