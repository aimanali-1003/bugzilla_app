# frozen_string_literal: true

FactoryBot.define do
  factory :bug do
    title { "#{Faker::Name.first_name}abcd" }
    description { Faker::Internet.email }
    deadline { Time.zone.today }
    bugtype { 0 }
    status { 0 }
    association :project_id, factory: :project
    association :posted_by_id, factory: :user
    association :posted_by, factory: :qa
    association :project, factory: :project
    association :assigned_to, factory: :developer

    images { fixture_file_upload '/home/dev/bugzilla/app/assets/images/valid_image.png', 'image/png' }
  end
end
