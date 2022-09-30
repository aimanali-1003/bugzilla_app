# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:user) }
end
