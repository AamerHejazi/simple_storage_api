# spec/factories/storage_types.rb
FactoryBot.define do
    factory :storage_type do
      sequence(:id) { |n| n }
      sequence(:type_name) { |n| "Type #{n}" }
  
      trait :database do
        id { 1 }
        type_name { "Database" }
      end
  
      trait :s3 do
        id { 2 }
        type_name { "S3" }
      end
  
      trait :local do
        id { 3 }
        type_name { "Local" }
      end
  
      trait :ftp do
        id { 4 }
        type_name { "FTP" }
      end
    end
  end  