class RemoveTypeIdFromStorageTypes < ActiveRecord::Migration[7.1]
  def change
    remove_column :storage_types, :type_id, :integer
  end
end
