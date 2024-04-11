class AddUniqueIndexToBlobs < ActiveRecord::Migration[7.1]
  def change
    add_index :blobs, [:user_id, :id], unique: true
  end
end
