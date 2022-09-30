# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    association :creator, factory: :user
    name { Faker::Name.first_name }
    description { Faker::Internet.email }
  end
end
