class CreateBlobData < ActiveRecord::Migration[7.1]
  def change
    create_table :blob_data do |t|
      t.references :blob, null: false, foreign_key: true
      t.text :data

      t.timestamps
    end
  end
end
