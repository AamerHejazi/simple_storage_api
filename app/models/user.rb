    class User < ApplicationRecord
        has_secure_password
        
        validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
        validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

        has_many :auth_tokens, dependent: :destroy
        has_many :blobs, dependent: :destroy
    end
