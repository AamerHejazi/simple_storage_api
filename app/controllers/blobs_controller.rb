# app/controllers/blobs_controller.rb
class BlobsController < ApplicationController
  before_action :authenticate_user

  def create
    # Decode Base64 data and handle potential errors
    begin
      decoded_data = Base64.strict_decode64(params[:data])
      size_in_bytes = decoded_data.bytesize
    rescue ArgumentError
      return render json: { error: 'Invalid Base64 data' }, status: :bad_request
    end

    # Check if the blob ID is unique for the current user
    if current_user.blobs.exists?(id: params[:id])
      return render json: { error: 'Blob ID already exists for this user' }, status: :bad_request
    end

    # Select the storage service based on configuration or user choice
    storage_service = select_storage_service

    # Store the blob using the selected service
    result = storage_service.store(params[:id], params[:data], size_in_bytes, current_user)

    if result.success?
      render json: { id: result.blob.id, data: params[:data], size: size_in_bytes, created_at: result.blob.created_at }, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def show
    storage_service = select_storage_service
    result = storage_service.retrieve(params[:id], current_user)

    if result.success?
      blob = result.blob
      blob_data = result.data
      render json: {
        id: blob.id,
        data: blob_data,
        size: blob.size,
        created_at: blob.created_at
      }, status: :ok
    else
      render json: { error: 'Blob not found' }, status: :not_found
    end
  end

  private

  def select_storage_service
    case ENV['STORAGE_SERVICE']
    when 'DB'
      DBBlobStorageService.new
    when 'S3'
      S3BlobStorageService.new
    when 'Local'
      LocalBlobStorageService.new
    when 'FTP'
      FTPBlobStorageService.new
    else
      raise 'Storage service not selected'
    end
  end

  def authenticate_user
    # Extract the bearer token from the Authorization header
    bearer_token = request.headers['Authorization']&.split(' ')&.last

    # Find the token and check if it's expired
    auth_token = AuthToken.find_by(token: bearer_token)
    if auth_token && auth_token.expires_at > Time.current
      # Token is valid, set current_user
      @current_user = auth_token.user
    else
      # Token is invalid or expired, render an error
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end

  # Use this method to access the current user in your actions
  def current_user
    @current_user
  end
end
