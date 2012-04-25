class CreateDemands < ActiveRecord::Migration
  def change
    create_table :demands do |t|
      t.references :blackmail, null: false
      t.string :description
      t.boolean :completed, default: false, null: false
    end
    
    add_index :demands, :blackmail_id
    
  end
end
