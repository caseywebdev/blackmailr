class CreateDemands < ActiveRecord::Migration
  def change
    create_table :demands do |t|
      t.string :description
      t.boolean :completed, default: false, null: false
    end
  end
end
