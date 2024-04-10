# app/services/token_generation_service.rb
class TokenGenerationService
    def self.generate_token_for_user(user)
      auth_token = user.auth_tokens.create!(expires_at: 24.hours.from_now)
      auth_token.token
    end
  end
  