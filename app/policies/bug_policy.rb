# frozen_string_literal: true

class BugPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def new?
    return true if @user.QA?

    false
  end

  def create?
    return true if @user.QA?

    false
  end

  def edit?
    return true if @record.posted_by == @user

    false
  end

  def show?
    return true if @record.posted_by == @user || @user.project_enrollment.include?(@record.project)

    false
  end

  def update?
    return true if @user.Developer? && @user.project_enrollment.include?(@record.project) || @record.posted_by == @user

    false
  end

  def status?
    return true if @user.Developer?

    false
  end
end
