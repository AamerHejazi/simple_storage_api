require 'rest-client'
require 'openssl'
require 'base64'
require 'uri'
require 'cgi'
require 'time'

class BlobS3StorageService
  include BlobStorageInterface

  # '2' is the ID for s3 storage
  STORAGE_TYPE_ID = 2
  END_POINT = ENV['MINIO_URL']
  BUCKET = ENV['MINIO_BUCKET']
  ACCESS_KEY = ENV['MINIO_ACCESS_KEY']
  SECRET_KEY = ENV['MINIO_SECRET_KEY']
  REGION = ENV['MINIO_REGION']

  def store(file_name, encoded_data, size, user)

    # Check if the file name already exists for the current user
    existing_blob = user.blobs.find_by(id: file_name)
    return OpenStruct.new(success?: false, error: 'File name already exists for this user') if existing_blob

    begin
      file_data = Base64.decode64(encoded_data.gsub("\n", ''))
      mime_type = Marcel::MimeType.for(StringIO.new(file_data)) || 'application/octet-stream'
      extension = File.extname(file_name).presence || MIME::Types[mime_type].first&.preferred_extension || 'bin'
      file_name_with_extension = "#{file_name}.#{extension}"

      uri = URI.parse("#{END_POINT}/#{BUCKET}/#{CGI.escape(file_name_with_extension)}")
      amz_date = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
      datestamp = Time.now.utc.strftime('%Y%m%d')

      headers = {
        'Host' => uri.host,
        'Content-Type' => mime_type,
        'X-Amz-Content-Sha256' => sha256_hex(file_data),
        'X-Amz-Date' => amz_date
      }

      authorization = signature_v4('PUT', uri, headers, file_data, amz_date, datestamp)
      headers['Authorization'] = authorization

      # Print URL and headers for debugging
      #puts "URL: #{uri.to_s}"
      #headers.each { |k, v| puts "#{k}: #{v}" }
      
      response = RestClient.put(uri.to_s, file_data, headers)

      unless response.code.between?(200, 299)
        return OpenStruct.new(success?: false, error: "Failed with status code: #{response.code}")
      end

      blob = user.blobs.create!(
        id: file_name,
        file_name: file_name_with_extension,
        path: "/#{BUCKET}/#{file_name_with_extension}",
        size: file_data.bytesize,
        storage_type_id: STORAGE_TYPE_ID
      )

        OpenStruct.new(success?: true, blob: blob)
      rescue ArgumentError
        OpenStruct.new(success?: false, error: 'Invalid Base64 data')
      rescue RestClient::Exception => e
        OpenStruct.new(success?: false, error: e.message)  
      end
  end
  

  def retrieve(blob_id, user)
    # Step 1: Find the blob in the database
  blob = user.blobs.find_by(id: blob_id)

  return OpenStruct.new(success?: false, error: 'Blob not found') unless blob

  # Step 2: Construct the URI for the GET request
  uri = URI.parse("#{END_POINT}/#{BUCKET}/#{CGI.escape(blob.file_name)}")

  # Step 3: Prepare and sign headers
  amz_date = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
  datestamp = Time.now.utc.strftime('%Y%m%d')
  headers = {
    'Host' => "#{uri.host}",
    'X-Amz-Date' => amz_date,
    'X-Amz-Content-Sha256' => 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  }

  authorization = signature_v4('GET', uri, headers, '', amz_date, datestamp)
  headers['Authorization'] = authorization
  puts(headers)
  # Step 4: Make the GET request
  begin
    response = RestClient.get(uri.to_s, headers)
    if response.code.between?(200, 299)
      OpenStruct.new(success?: true, id: blob.id, data: Base64.strict_encode64(response.body), size: blob.size, created_at: blob.created_at)
    else
      OpenStruct.new(success?: false, error: "Failed to retrieve blob with status code: #{response.code}")
    end
    rescue RestClient::Exception => e
      puts(e.message)
      OpenStruct.new(success?: false, error: e.message)
    rescue => e
      puts(e.message)
      OpenStruct.new(success?: false, error: e.message)
    end
  end

  def sha256_hex(data)
    Digest::SHA256.hexdigest(data)
  end

  def sign(key, msg)
    OpenSSL::HMAC.digest('sha256', key, msg)
  end

  def get_signature_key(key, date_stamp, region_name, service_name)
    k_date = sign("AWS4" + key, date_stamp)
    k_region = sign(k_date, region_name)
    k_service = sign(k_region, service_name)
    k_signing = sign(k_service, 'aws4_request')
    k_signing
  end

  def signature_v4(method, uri, headers, payload, amz_date, datestamp)
    canonical_uri = uri.path
    canonical_querystring = ''
    canonical_headers = headers.sort.map { |k, v| "#{k.downcase}:#{v.strip}\n" }.join
    signed_headers = headers.keys.sort.map(&:downcase).join(';')
    payload_hash = sha256_hex(payload)
    canonical_request = [method, canonical_uri, canonical_querystring, canonical_headers, signed_headers, payload_hash].join("\n")

    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = "#{datestamp}/#{REGION}/s3/aws4_request"
    string_to_sign = [algorithm, amz_date, credential_scope, sha256_hex(canonical_request)].join("\n")

    signing_key = get_signature_key(SECRET_KEY, datestamp, REGION, 's3')
    signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)

    "#{algorithm} Credential=#{ACCESS_KEY}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
  end

end