require 'rails_helper'

RSpec.describe "Blobs API", type: :request do
    let(:user) { create(:user) }
    let(:token) { login_user_and_get_token(user) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }
    let(:temp_file) do
        Tempfile.new(['test', '.bin']).tap do |f|
        f.binmode
        f.write(Random.bytes(10))  # Write random binary data
        f.rewind
        end
  end
  let(:storage_type) { create(:storage_type, :database) } 
  let(:valid_data) { Base64.strict_encode64(File.read(temp_file.path, mode: 'rb')) }
  let(:invalid_data) { '!!!***@@@' }
    before do
        storage_type
    end
  after do
    temp_file.close
    temp_file.unlink
  end

  describe 'POST /v1/blobs' do
    context 'when parameters are missing' do
      it 'returns a bad request for missing data' do
        post '/v1/blobs', params: { id: 'unique-id' }, headers: headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a bad request for missing id' do
        post '/v1/blobs', params: { data: valid_data }, headers: headers
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the file name is unique' do
      it 'stores the blob successfully' do
        puts "Params: #{ { id: 'unique-id', data: valid_data } }"
        expect {
          post '/v1/blobs', params: { id: 'unique-id', data: valid_data }, headers: headers
        }.to change(Blob, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the file name already exists' do
      before do
        post '/v1/blobs', params: { id: 'duplicate-id', data: valid_data }, headers: headers
      end

      it 'returns an error' do
        post '/v1/blobs', params: { id: 'duplicate-id', data: valid_data }, headers: headers
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with invalid data' do
      it 'returns a bad request status' do
        post '/v1/blobs', params: { id: 'new-id', data: invalid_data }, headers: headers
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET /v1/blobs/:id' do
    let!(:blob) { create(:blob, user: user, id: 'unique-id') }

    it 'retrieves the blob successfully' do
      get "/v1/blobs/#{blob.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('unique-id')
    end

    it 'returns an error if the blob does not exist' do
      get '/v1/blobs/nonexistent-id', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end