class UsersController < ApplicationController
  def create
    user_params = params.permit(:email, :password, :password_confirmation)
    registration_service = UserRegistrationService.new
    result = registration_service.register(user_params)

    if result.success?
      render json: { id: result.user.id, email: result.user.email }, status: :created
    else
      render json: { errors: result.errors }, status: :bad_request
    end
  end
end
  