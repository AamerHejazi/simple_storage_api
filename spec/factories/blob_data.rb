FactoryBot.define do
    factory :blob_data do
      blob
      data { Base64.encode64('Hello World') }
    end
  end