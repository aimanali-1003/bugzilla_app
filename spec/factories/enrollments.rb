# frozen_string_literal: true

FactoryBot.define do
  factory :enrollment do
    association :enrolled_users, factory: :developer
    association :enrolled_users_id, factory: :developer
  end
end
