require 'aws-sdk-s3'
require 'base64'
require 'mime/types'

class BlobS3StorageService
  include BlobStorageInterface

  def store(file_name, encoded_data, size, user)
    # Decode the base64-encoded data
    file_data = Base64.decode64(encoded_data)

    # Check if the file name already exists for the current user
    existing_blob = user.blobs.find_by(id: file_name)
    if existing_blob
      # If the file name exists, return an error
      return OpenStruct.new(success?: false, error: 'File name already exists for this user')
    end

    # Detect MIME type using Marcel
    mime_type = Marcel::MimeType.for(StringIO.new(file_data))

    # Get the appropriate file extension using mime-types gem
    extension = MIME::Types[mime_type].first.preferred_extension if MIME::Types[mime_type].any?

    # Construct the file name with the detected or default extension
    file_name_with_extension = "#{file_name}.#{extension || 'bin'}"
    bucket_name = ENV['MINIO_BUCKET']
    puts(bucket_name)
    # Initialize the S3 client
    s3_client = Aws::S3::Client.new(
      endpoint: ENV['MINIO_URL'],
      access_key_id: ENV['MINIO_ACCESS_KEY'],
      secret_access_key: ENV['MINIO_SECRET_KEY'],
      region: 'us-east-1',  # This can be a dummy region if not used by MinIO
      force_path_style: true
    )

    # Attempt to upload the file to S3
    begin
      s3_client.put_object(
        bucket: bucket_name,
        key: file_name_with_extension,
        body: file_data,
        content_type: mime_type || 'application/octet-stream'
      )

      # Save the file information in the database
      blob = user.blobs.create!(
        id: file_name,
        file_name: file_name_with_extension,
        path: "/#{bucket_name}/#{file_name_with_extension}",
        size: file_data.bytesize,
        storage_type_id: 2 # Assuming '2' is the ID for S3 storage
      )

      OpenStruct.new(success?: true, blob: blob)
    rescue Aws::S3::Errors::ServiceError => e
      # If the upload fails, return an error using OpenStruct
      OpenStruct.new(success?: false, error: e.message)
    end
  end
  def retrieve(blob_id, user)
    # Find the blob record associated with the given blob_id and user
    blob = user.blobs.find_by(id: blob_id)

    return OpenStruct.new(success?: false, error: 'Blob not found') unless blob

    # Initialize the S3 client
    s3_client = Aws::S3::Client.new(
      endpoint: ENV['MINIO_URL'],
      access_key_id: ENV['MINIO_ACCESS_KEY'],
      secret_access_key: ENV['MINIO_SECRET_KEY'],
      region: 'us-east-1',  # This can be a dummy region if not used by MinIO
      force_path_style: true
    )

    begin      
      response = s3_client.get_object(
        bucket: ENV['MINIO_BUCKET'],
        key: blob.file_name
      )

      # Read the file content from the response
      file_content = Base64.strict_encode64(response.body.read)

      # Return the file content and MIME type
      OpenStruct.new(success?: true, id:blob.id, data: file_content, mime_type: response.content_type, size: blob.size, created_at: blob.created_at)
    rescue Aws::S3::Errors::ServiceError => e
      # If the retrieval fails, return an error
      puts(e.message)
      OpenStruct.new(success?: false, error: e.message)
    end
  end

  private

end
