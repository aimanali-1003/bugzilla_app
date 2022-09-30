# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    # association :project
    name { Faker::Name.name }
    email {  Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    role { 0 }
    trait :developer do
      role { 1 }
    end
    trait :qa do
      role { 2 }
    end
    factory :qa, traits: [:qa]
    factory :developer, traits: [:developer]
  end
end
