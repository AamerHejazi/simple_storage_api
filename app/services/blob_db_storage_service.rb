class BlobDbStorageService
    include BlobStorageInterface
  
    #'1' is the ID for database storage in your storage_types table
    STORAGE_TYPE_ID = 1
  
    def store(file_name, data, size, user)

      # Check if the file name already exists for the current user
    existing_blob = user.blobs.find_by(id: file_name)

    if existing_blob
      # If the file name exists, return an error
      return OpenStruct.new(success?: false, error: 'File name already exists for this user')
    end

    # Decode the base64-encoded data
    file_data = Base64.decode64(data)

    # Detect MIME type using Marcel
    mime_type = Marcel::MimeType.for(StringIO.new(file_data))

    # Get the appropriate file extension using mime-types gem
    extension = MIME::Types[mime_type].first.preferred_extension if MIME::Types[mime_type].any?

    # Construct the file name with the detected or default extension
    file_name_with_extension = "#{file_name}.#{extension || 'bin'}"

    ActiveRecord::Base.transaction do
      # Create the Blob record first
      blob = user.blobs.create!(id: file_name, file_name: file_name_with_extension, size: size, storage_type_id: STORAGE_TYPE_ID)
      # Now you can safely create the associated BlobData record
      BlobData.create!(blob: blob, data: data)
      # Return the blob if everything is successful
      OpenStruct.new(success?: true, blob: blob)
    end
    rescue ActiveRecord::RecordInvalid => e
      # Handle any validation failures or other issues here
      OpenStruct.new(success?: false, errors: e.record.errors.full_messages)
    end
  
    def retrieve(file_name, user)
      blob = user.blobs.find_by(id: file_name)
  
      if blob
        blob_data = blob.blob_data
        OpenStruct.new(success?: true, id: blob.id, data: blob_data.data, size: blob.size, created_at: blob.created_at)
      else
        OpenStruct.new(success?: false, errors: ['Blob not found'])
      end
    end
  end  