class AuthToken < ApplicationRecord
  belongs_to :user

   # Callback to generate a unique token before creating a new AuthToken record
   before_create :generate_unique_secure_token

   # Callback to set the expiration time for the token
   before_create :set_expiration_time
 
   private
 
   def generate_unique_secure_token
     self.token = SecureRandom.hex(10) # Generates a random token
   end
 
   def set_expiration_time
     self.expires_at ||= 24.hours.from_now # Sets the token to expire in 24 hours
   end
end
