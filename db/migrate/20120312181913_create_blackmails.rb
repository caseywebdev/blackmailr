class CreateBlackmails < ActiveRecord::Migration
  def change
    create_table :blackmails do |t|
      t.references  :user, null: false
      t.string      :title,
                    :description,
                    :victim_name,
                    :victim_email, null: false
      t.datetime    :end_at
      t.timestamps
    end
  end
end
