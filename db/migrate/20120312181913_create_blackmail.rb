class CreateBlackmail < ActiveRecord::Migration
  def change
    create_table :blackmail do |t|
      t.references  :user, null: false
      t.string      :title,
                    :description,
                    :victim_name,
                    :victim_email, null: false
      t.datetime    :expired_at
      t.timestamps
    end
    
    add_index :blackmail, :user_id
    
  end
end
