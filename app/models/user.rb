class User < ApplicationRecord
    has_secure_password
    has_many :auth_tokens, dependent: :destroy
    has_many :blobs, dependent: :destroy
end
