class Blob < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :storage_type
  has_one :blob_data, dependent: :destroy
  belongs_to :user

  validates :id, presence: true, uniqueness: { scope: :user_id },
                 format: { without: /\.[a-zA-Z0-9]+\z/, message: "should not end with a file extension like .pdf, .jpg, etc." }
end
