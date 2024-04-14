# test/services/blob_db_storage_service_test.rb

require 'test_helper'

class BlobDbStorageServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one) # Assuming you have a fixtures file for users
    @service = BlobDbStorageService.new
    @file_name = 'test_file'
    @data = Base64.encode64('Hello World')
    @size = @data.size
  end

  test 'store method should save a new blob if file name does not exist' do
    assert_difference 'Blob.count', 1 do
      result = @service.store(@file_name, @data, @size, @user)
      assert result.success?
      assert_equal @file_name, result.blob.id
    end
  end

  test 'store method should not save a blob if file name already exists' do
    # Create a blob with the same file name first
    @user.blobs.create!(id: @file_name, file_name: "#{@file_name}.bin", size: @size, storage_type_id: BlobDbStorageService::STORAGE_TYPE_ID)

    assert_no_difference 'Blob.count' do
      result = @service.store(@file_name, @data, @size, @user)
      assert_not result.success?
      assert_equal 'File name already exists for this user', result.error
    end
  end

  test 'retrieve method should return blob data if blob exists' do
    blob = @user.blobs.create!(id: @file_name, file_name: "#{@file_name}.bin", size: @size, storage_type_id: BlobDbStorageService::STORAGE_TYPE_ID)
    BlobData.create!(blob: blob, data: @data)

    result = @service.retrieve(@file_name, @user)
    assert result.success?
    assert_equal @data, result.data
  end

  test 'retrieve method should return error if blob does not exist' do
    result = @service.retrieve('nonexistent_file', @user)
    assert_not result.success?
    assert_includes result.errors, 'Blob not found'
  end
end
