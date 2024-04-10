class AuthenticationController < ApplicationController
    def create
      user = User.find_by(email: params[:email])
      if user && user.authenticate(params[:password])
        # Check for existing non-expired tokens
        existing_token = user.auth_tokens.where('expires_at > ?', Time.current).first
        
        if existing_token
          # Return the existing token if it hasn't expired
          render json: { bearer_token: existing_token.token, expires_at: existing_token.expires_at }, status: :ok
        else
          # Generate a new token if no non-expired token exists
          new_token = user.auth_tokens.create!(expires_at: 24.hours.from_now)
          render json: { bearer_token: new_token.token, expires_at: new_token.expires_at }, status: :ok
        end
      else
        render json: { error: 'Invalid credentials' }, status: :unauthorized
      end
    end
  end
  