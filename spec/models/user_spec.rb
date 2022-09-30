# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:manager_user) { FactoryBot.create(:user, name: 'Alian', role: 0) }
  let(:qa) { FactoryBot.create(:user, :qa) } # qa
  let(:developer) { FactoryBot.create(:user, :developer) } # developer

  it { is_expected.to have_many(:projects).with_foreign_key('creator_id').dependent(:delete_all) }
  it { is_expected.to have_many(:bugs).through(:projects) }
  it { is_expected.to have_many(:enrollments).dependent(:delete_all) }

  it do
    expect(subject).to have_many(:project_enrollment)
      .through(:enrollments)
      .source(:project)
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to define_enum_for(:role).with_values(%i[Manager Developer QA]) }

  describe '#name_role' do
    it 'returns user name and role' do
      expect(manager_user.name_role).to eq('Alian Manager')
    end
  end

  describe 'scopes test' do
    it 'includes user name with developer role' do
      expect(described_class.devs).to include(developer)
    end

    it 'includes user name with qa role' do
      expect(described_class.qas).to include(qa)
    end
  end
end
