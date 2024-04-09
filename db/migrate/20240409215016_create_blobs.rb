class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs, id: false do |t|
      t.string :id, primary_key: true
      t.string :file_name
      t.integer :size
      t.string :path
      t.references :storage_type, null: false, foreign_key: true
      t.timestamps
    end
    add_index :blobs, :id, unique: true
  end
end
