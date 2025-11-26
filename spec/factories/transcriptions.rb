FactoryBot.define do
  factory :transcription do
    content { Faker::Lorem.paragraph(sentence_count: 5) }
    summary { Faker::Lorem.sentence(word_count: 15) }
    status { 'completed' }
    metadata { {} }

    trait :processing do
      status { 'processing' }
      summary { nil }
    end

    trait :failed do
      status { 'failed' }
      summary { nil }
      metadata { { error: 'API Error' } }
    end

    trait :with_summary do
      summary { Faker::Lorem.sentence(word_count: 20) }
      status { 'completed' }
    end
  end
end

