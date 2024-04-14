require 'rails_helper'

RSpec.describe BlobDbStorageService do
  let(:user) { create(:user) }
  let(:temp_file) do
    Tempfile.new(['test', '.bin']).tap do |f|
      f.binmode
      f.write(Random.bytes(10))  # Write random binary data
      f.rewind
    end
  end
  let(:valid_data) { Base64.strict_encode64(File.read(temp_file.path, mode: 'rb')) }
  let(:invalid_data) { '!!!***@@@' }
  let(:storage_type) { create(:storage_type, :database) } 
  
  before do
    # Ensure the correct storage type is set up for testing
    storage_type
  end
  after do
    temp_file.close
    temp_file.unlink  # Ensures that the tempfile is deleted afterwards
  end
  describe "#store" do
    context "when the file name is unique" do
      it "stores the blob successfully" do
        service = BlobDbStorageService.new
        result = service.store('unique-id', valid_data, valid_data.length, user)
        puts result.inspect
        expect(result.success?).to be true
        expect(Blob.count).to eq(1)
        expect(result.blob.file_name).to include('unique-id')
        expect(result.blob.storage_type_id).to eq(BlobDbStorageService::STORAGE_TYPE_ID)
      end
    end

    context "when the file name already exists" do
      before do
        user.blobs.create!(id: 'duplicate-id', file_name: 'duplicate-id.bin', size: 12, storage_type_id: BlobDbStorageService::STORAGE_TYPE_ID)
      end

      it "returns an error" do
        service = BlobDbStorageService.new
        result = service.store('duplicate-id', valid_data, valid_data.length, user)
        expect(result.success?).to be false
        expect(result.error).to eq('File name already exists for this user')
      end
    end

    context "with invalid data" do
      it "handles Base64 decode errors" do
        service = BlobDbStorageService.new
        result = service.store('new-id', invalid_data, invalid_data.length, user)
        expect(result.success?).to be false
        expect(result.error).to eq('Invalid Base64 data')
      end 
    end
  end

  describe "#retrieve" do
    let(:blob) { create(:blob, user: user, id: 'unique-id', storage_type_id: storage_type.id) }

    it "retrieves the blob successfully" do
      create(:blob_data, blob: blob, data: valid_data)
      service = BlobDbStorageService.new
      result = service.retrieve('unique-id', user)
      expect(result.success?).to be true
      expect(result.data).to eq(valid_data)
    end

    it "returns an error if the blob does not exist" do
      service = BlobDbStorageService.new
      result = service.retrieve('nonexistent-id', user)
      expect(result.success?).to be false
      expect(result.errors).to include('Blob not found')
    end
  end
end