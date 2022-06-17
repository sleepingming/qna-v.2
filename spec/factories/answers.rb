FactoryBot.define do
  factory :answer do
    body { 'MyText' }
    question
    user

    factory :same_answer do
      body { 'SameAnswerText' }
    end

    trait :invalid do
      body { nil }
      question_id { nil }
    end
  end
end
