class AddImageToBlackmails < ActiveRecord::Migration
  def change
    add_column :blackmails, :image, :bytea
  end
end
