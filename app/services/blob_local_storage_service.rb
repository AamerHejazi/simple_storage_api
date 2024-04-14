require 'fileutils'
require 'base64'
require 'mime/types'

class BlobLocalStorageService
  include BlobStorageInterface

  # Base directory for local storage on the D: drive
  BASE_STORAGE_PATH = ENV['BASE_STORAGE_PATH']
  # '3' is the ID for local storage
  STORAGE_TYPE_ID = 3

  def initialize
    # Ensure the base storage directory exists
    FileUtils.mkdir_p(BASE_STORAGE_PATH) unless Dir.exist?(BASE_STORAGE_PATH)
  end

  def store(file_name, encoded_data, size, user)

    # Check if the file name already exists for the current user
    existing_blob = user.blobs.find_by(id: file_name)
    if existing_blob
      # If the file name exists, return an error
      return OpenStruct.new(success?: false, error: 'File name already exists for this user')
    end

    # Create a directory for the user if it doesn't exist
    user_storage_path = File.join(BASE_STORAGE_PATH, "user_#{user.id}")
    FileUtils.mkdir_p(user_storage_path) unless Dir.exist?(user_storage_path)

    # Decode the base64-encoded data
    begin
      file_data = Base64.strict_decode64(data)
    rescue ArgumentError
      return OpenStruct.new(success?: false, error: 'Invalid Base64 data')
    end

    # Detect MIME type using Marcel
    mime_type = Marcel::MimeType.for(StringIO.new(file_data))

    # Get the appropriate file extension using mime-types gem
    extension = MIME::Types[mime_type].first.preferred_extension if MIME::Types[mime_type].any?

    # Construct the file name with the detected or default extension
    file_name_with_extension = "#{file_name}.#{extension || 'bin'}"

    # Construct the file path within the user's directory
    file_path = File.join(user_storage_path, file_name_with_extension)

    # Write the file data to the file system
    File.open(file_path, 'wb') { |file| file.write(file_data) }

    # Save the file information in the database
    blob = user.blobs.create!(
      id:file_name,
      file_name: file_name_with_extension,
      path: file_path,
      size: file_data.bytesize,
      storage_type_id: STORAGE_TYPE_ID
    )

    # Return an OpenStruct indicating success and containing the blob object
    OpenStruct.new(success?: true, blob: blob)
  rescue StandardError => e
    # If an error occurs, return an OpenStruct indicating failure
    OpenStruct.new(success?: false, error: e.message)
  end

  def retrieve(blob_id, user)
    # Find the blob record associated with the given blob_id and user
    blob = user.blobs.find_by(id: blob_id)
    return OpenStruct.new(success?: false, error: 'Blob not found in database') unless blob

    file_path = File.join(BASE_STORAGE_PATH, "user_#{user.id}", blob.file_name)

    # Return an error if the file does not exist on the filesystem
    return OpenStruct.new(success?: false, error: 'File not found on local storage') unless File.exist?(file_path)

    # Read the file content from the file system
    file_content = File.binread(file_path)
    # Encode the file content as base64
    encoded_file_content = Base64.strict_encode64(file_content)

    # Return an OpenStruct with the file content and MIME type
    OpenStruct.new(success?: true, id: blob.id, data: encoded_file_content, size: blob.size, created_at: blob.created_at)
    rescue StandardError => e
      # If an error occurs during retrieval, return an OpenStruct indicating failure
      OpenStruct.new(success?: false, error: e.message)
  end

end
