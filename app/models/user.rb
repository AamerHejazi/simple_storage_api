class User < ApplicationRecord
    has_secure_password
    
    validates :email, presence: true, uniqueness: true

    has_many :auth_tokens, dependent: :destroy
    has_many :blobs, dependent: :destroy
end
