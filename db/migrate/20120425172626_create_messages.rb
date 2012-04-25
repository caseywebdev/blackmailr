class CreateMessages < ActiveRecord::Migration
  
  def change
    create_table :messages do |t|
      t.references  :blackmail, null: false
      t.text        :content
      t.boolean     :from_victim, null: false, default: false
      t.datetime    :created_at
    end
    add_index :messages, :blackmail_id
  end
  
end
