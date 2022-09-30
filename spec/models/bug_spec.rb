# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bug, type: :model do
  let(:post) { FactoryBot.build(:bug) }

  it { is_expected.to belong_to(:project) }
  it { is_expected.to have_many_attached(:images) }
  it { is_expected.to belong_to(:posted_by).class_name('User') }
  it { is_expected.to belong_to(:assigned_to).class_name('User').optional }
  it { is_expected.to validate_presence_of(:bugtype) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to define_enum_for(:bugtype).with_values(%i[Bug Feature]) }
  it { is_expected.to define_enum_for(:status).with_values(%i[New Started Completed Resolved]) }

  describe 'validations' do
    subject { FactoryBot.build(:bug) }

    it { is_expected.to validate_uniqueness_of(:title) }
  end

  context 'image_type' do
    it 'when image is present and content type is valid' do
      post.image_type
      expect(post.errors).not_to have_key(:images)
    end

    # it 'when content type is valid' do
    #   # valid image
    #   post.image_type
    #   expect(post.errors).not_to have_key(:images)
    # end
  end
end
