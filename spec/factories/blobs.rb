FactoryBot.define do
    factory :blob do
      id { "test_file132" } 
      file_name { "test_file123.txt" } 
      size { 1024 } 
      storage_type_id { StorageType.find_by(type_name: 'Local').id }
      user
    end
  end