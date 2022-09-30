# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:manager) { FactoryBot.create(:user) }
  let(:qa) { FactoryBot.create(:user, :qa) }
  let(:developer) { FactoryBot.create(:user, :developer) }
  let!(:project1) { FactoryBot.create(:project) }

  let(:project_params) { attributes_for(:project, u_id: [manager.id]) }
  let(:project_invalid_params) { attributes_for(:project, name: nil, project_id: project1.id, u_id: [manager.id]) }

  before do
    sign_in manager
  end

  it { is_expected.to use_before_action(:set_project) }
  it { is_expected.to use_before_action(:authorize_project) }

  describe 'Get Project#index' do
    context 'when user is manager' do
      it 'renders a template of index' do
        get :index
        expect(subject).to render_template('index')
        expect(response.status).to eq 200
      end
    end

    context 'when user is QA' do
      it 'renders a template of index' do
        sign_in qa
        get :index
        expect(subject).to render_template('index')
        expect(response.status).to eq 200
      end
    end

    context 'when user is Developer' do
      before 'Developer must be signed in' do
        sign_in developer
        get :index
      end

      it 'renders a template of index' do
        expect(subject).to render_template('index')
        expect(response.status).to eq 200
      end
    end
  end

  describe 'Get Project#new' do
    context 'User signed in as Manager' do
      it 'render new template for manager' do
        get :new
        expect(subject).to render_template('new')
      end
    end

    context 'User signed in as Developer' do
      before 'developer must sign in' do
        sign_in developer
        get :new
      end

      it 'shows a flash of not authorized' do
        flash[:alert] = 'You are not authorized to perform this action'
      end
    end

    context 'User signed in as QA' do
      before 'QA must be signed in' do
        sign_in qa
        get :new
      end

      it 'shows a flash of not authorized' do
        flash[:alert] = 'You are not authorized to perform this action'
      end
    end
  end

  describe 'POST Project#create' do
    context 'Project created with valid params' do
      before do
        get :new
        post :create, params: { project: project_params }
      end

      it 'create a project' do
        expect do
          post :create, params: { project: project_params }
        end.to change(Project, :count).by(1)
      end

      it 'redirects successfully to projects path' do
        expect(response).to redirect_to projects_path
        expect(flash[:notice]).to eq(I18n.t('create'))
      end

      context 'Invalid case for create' do
        it 'Project not created' do
          post :create, params: { project: project_invalid_params }
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe 'PUT Projects#update' do
    context 'user is logged in as manager' do
      before 'Manager must sign-in' do
        sign_in project1.creator
      end

      context 'when project is updated with valid params' do
        before do
          # byebug
          patch :update, params: { project: { name: 'aiman' }, id: project1.id }
        end

        it 'update project' do
          project1.reload
          expect(project1.name).to eq('aiman')
          expect(response).to redirect_to project_url(project1.id)
        end
      end

      context 'if user is logged in as developer' do
        before 'developer must be signed in' do
          sign_in developer
        end

        before do
          patch :update, params: {
            project: project_params,
            id: project1.id
          }
        end

        it 'shows a flash of not authorized' do
          flash[:alert] == eq('You are not authorized to perform this action')
        end
      end

      context 'Invalid case for update' do
        it 'not creating the project' do
          patch :update, params: { project: project_invalid_params, id: project1.id }
          expect(response).to render_template('edit')
        end
      end
    end
  end

  describe 'Delete Projects#destroy' do
    before do
      sign_in project1.creator
    end

    context 'when manager destroy the project' do
      it 'successfully deletes a project, decrement count and redirect to projects path' do
        expect do
          delete :destroy,
                 params: { id: project1.id }
        end.to change(Project, :count).by(-1)
        expect(flash[:notice]).to eq(I18n.t('destroy'))
        expect(response).to redirect_to projects_path
      end
    end

    context 'Invalid case for destroy' do
      it 'project not destroyed' do
        allow_any_instance_of(Project).to receive(:destroy).and_return(false)
        expect do
          delete :destroy, params: { manager_id: manager.id, id: project1.id }
        end.to change(Project, :count).by(0)
      end
    end
  end
end
