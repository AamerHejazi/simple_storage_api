class UsersController < ApplicationController
  
    def create
      registration_service = UserRegistrationService.new
      result = registration_service.register(
        params[:email], 
        params[:password], 
        params[:password_confirmation]
      )
      
      if result.success?
        render json: { id: result.user.id, email: result.user.email }, status: :created
      else
        render json: { errors: result.errors }, status: :bad_request
      end
    end
  end
  