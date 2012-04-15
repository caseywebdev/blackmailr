class AddUpdateAtToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :updated_at, :datetime

  end
end
