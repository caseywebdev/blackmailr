class AddBlackmailIdToDemands < ActiveRecord::Migration

  def change
    add_column :demands, :blackmail_id, :integer
    add_index :demands, :blackmail_id
  end
  
end
