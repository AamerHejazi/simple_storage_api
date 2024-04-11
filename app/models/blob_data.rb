class BlobData < ApplicationRecord
  belongs_to :blob, primary_key: 'id', foreign_key: 'blob_id', class_name: 'Blob'
end
