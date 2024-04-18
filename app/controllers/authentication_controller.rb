class AuthenticationController < ApplicationController
  def create
    user = User.find_by(email: user_params[:email])

    if user&.authenticate(user_params[:password])
      token_service = TokenGenerationService.new(user)
      token = token_service.ensure_token
      render json: { bearer_token: token.token, expires_at: token.expires_at }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
