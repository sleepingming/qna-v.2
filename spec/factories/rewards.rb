FactoryBot.define do
  factory :reward do
    title { "MyReward" }
    image { Rack::Test::UploadedFile.new("#{Rails.root}/public/reward.png", 'image/png') }
  end
end
