FactoryBot.define do
  factory :link do
    name { 'MyLink' }
    url { 'http://google.com' }

    association :linkable
  end
end
