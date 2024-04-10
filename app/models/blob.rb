class Blob < ApplicationRecord
  self.primary_key = 'id'

  # Association with StorageType
  belongs_to :storage_type

  # Optional association with BlobData
  # Only exists if the blob is stored in the database
  has_one :blob_data, dependent: :destroy
end
