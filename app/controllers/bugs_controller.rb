# frozen_string_literal: true

class BugsController < ApplicationController
  before_action :set_bug_project
  before_action :set_bug, only: %i[show edit status update]
  before_action :authorize_bug, except: %i[index]

  def index
    @bugs = @project.bugs
  end

  def new
    @bug = @project.bugs.new
  end

  def create
    @bug = @project.bugs.new(set_params)
    @bug.posted_by = current_user

    if @bug.save
      redirect_to [@project, @bug]
      flash[:notice] = I18n.t 'create'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @bug.update(set_params)
      redirect_to [@project, @bug]
      flash[:notice] = I18n.t 'update'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def status
    if @bug.update(status: params[:status].to_i)
      redirect_to [@project, @bug], notice: 'Bug updated'
    else
      flash[:alert] = 'Status not updated'
    end
  end

  private

  def set_bug
    @bug = @project.bugs.find(params[:id])
  end

  def set_bug_project
    @project = Project.find(params[:project_id])
  end

  def authorize_bug
    if @bug.present?
      authorize @bug
    else
      authorize Bug
    end
  end

  def set_params
    params[:bug][:bugtype] = params[:bug][:bugtype].to_i
    params.require(:bug).permit(:title, :description, :deadline, :bugtype, :status, :assigned_to_id, images: [])
  end
end
