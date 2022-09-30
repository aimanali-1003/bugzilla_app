# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  it { is_expected.to belong_to(:creator).class_name('User') }
  it { is_expected.to have_many(:bugs).dependent(:destroy) }
  it { is_expected.to have_many(:enrollments).dependent(:delete_all) }

  it do
    expect(subject).to have_many(:enrolled_users)
      .through(:enrollments)
      .source(:user)
  end

  context 'when name is present' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
