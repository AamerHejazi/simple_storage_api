class CreateStorageTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :storage_types do |t|
      t.string :type_name

      t.timestamps
    end
  end
end
