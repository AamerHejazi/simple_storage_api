class ChangeBlobIdTypeToString < ActiveRecord::Migration[7.1]
  def change
    change_column :blob_data, :blob_id, :string
  end
end
