# app/services/token_generation_service.rb
class TokenGenerationService
  def initialize(user)
    @user = user
  end

  def ensure_token
    existing_token = @user.auth_tokens.where('expires_at > ?', Time.current).first
    existing_token || create_new_token
  end

  private

  def create_new_token
    @user.auth_tokens.create!(expires_at: 24.hours.from_now)
  end
end
