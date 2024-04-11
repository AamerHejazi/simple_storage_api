class Blob < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :storage_type
  has_one :blob_data, dependent: :destroy
  belongs_to :user

  validates :id, uniqueness: { scope: :user_id }
end
