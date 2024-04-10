class UsersController < ApplicationController
  
    def create
      registration_service = UserRegistrationService.new
      result = registration_service.register(
        params[:user][:email], 
        params[:user][:password], 
        params[:user][:password_confirmation]
      )
      
      if result.success?
        render json: { id: result.user.id, email: result.user.email }, status: :created
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end
  end
  