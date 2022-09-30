# frozen_string_literal: true

class Bug < ApplicationRecord
  belongs_to :project
  has_many_attached :images
  belongs_to :posted_by, class_name: :User
  belongs_to :assigned_to, class_name: :User, optional: true
  validates :bugtype, :status, presence: true
  validates :title, uniqueness: true, presence: true
  validate :image_type

  enum bugtype: { Bug: 0, Feature: 1 }
  enum status: { New: 0, Started: 1, Completed: 2, Resolved: 3 }

  def image_type
    images.each do |image|
      errors.add(:images, 'needs to be PNG or GIF') unless image.content_type.in?(%('image/png image/gif))
    end
  end
end
