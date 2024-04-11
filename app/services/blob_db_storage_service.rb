class BlobDbStorageService
    include BlobStorageInterface
  
    STORAGE_TYPE_ID = 1 # Assuming '1' is the ID for database storage in your storage_types table
  
    def store(id, data, size, user)
      ActiveRecord::Base.transaction do
        # Create the Blob record first
        blob = user.blobs.create!(id: id, size: size, storage_type_id: STORAGE_TYPE_ID)
        # Now you can safely create the associated BlobData record
        BlobData.create!(blob: blob, data: data)
        # Return the blob if everything is successful
        OpenStruct.new(success?: true, blob: blob)
      end
    rescue ActiveRecord::RecordInvalid => e
      # Handle any validation failures or other issues here
      OpenStruct.new(success?: false, errors: e.record.errors.full_messages)
    end
  
    def retrieve(id, user)
      blob = user.blobs.find_by(id: id)
  
      if blob
        blob_data = blob.blob_data
        OpenStruct.new(success?: true, blob: blob, data: blob_data.data)
      else
        OpenStruct.new(success?: false, errors: ['Blob not found'])
      end
    end
  end  