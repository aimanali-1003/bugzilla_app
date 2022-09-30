# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :projects, foreign_key: :creator_id, dependent: :delete_all
  has_many :bugs, through: :projects
  has_many :enrollments, dependent: :delete_all
  has_many :project_enrollment, through: :enrollments, source: :project
  validates :name, presence: true
  enum role: { Manager: 0, Developer: 1, QA: 2 }

  def name_role
    "#{name} #{role}"
  end

  scope :devs, -> { where(role: 'Developer') }
  scope :qas, -> { where(role: 'QA') }
end
