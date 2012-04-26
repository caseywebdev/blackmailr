class AddImageToBlackmail < ActiveRecord::Migration
  def change
    add_column :blackmail, :image, :bytea
  end
end
