class AddVictimTokenToBlackmail < ActiveRecord::Migration
  def change
    add_column :blackmail, :victim_token, :string

  end
end
