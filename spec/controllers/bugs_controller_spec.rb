# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BugsController, type: :controller do
  let(:manager) { FactoryBot.create(:user) }
  let(:developer) { FactoryBot.create(:user, :developer) }
  let(:qa) { FactoryBot.create(:user, :qa) }
  let!(:project) { FactoryBot.create(:project) }
  let!(:bug) { FactoryBot.create(:bug, project: project) }
  let(:enrollment) { create(:developer, project: project) }

  # let(:enrolled_users){ create(:user, :developer, project: project)}

  let(:set_params) do
    attributes_for(:bug, creator_id: qa.id, bugtype: 'Bug', status: 'New', project_id: project.id)
  end
  let(:bug_invalid_params) do
    attributes_for(:bug, creator_id: qa.id, title: nil, status: nil, project_id: nil)
  end
  let(:status_params) do
    attributes_for(:bug, status: 'Resolved')
  end

  before do
    sign_in qa
  end

  it { is_expected.to use_before_action(:set_bug) }
  it { is_expected.to use_before_action(:set_bug_project) }
  it { is_expected.to use_before_action(:authorize_bug) }

  describe 'Get Bug#index' do
    context 'When user is qa' do
      it 'render index template' do
        get :index, params: { project_id: project.id }
        expect(subject).to render_template('index')
      end
    end

    context 'When the user is manager' do
      before 'Manager must Sign-in' do
        sign_in manager
        get :index, params: { project_id: project.id }
      end

      it 'renders a template of index' do
        expect(subject).to render_template('index')
        expect(response.status).to eq 200
      end
    end

    context 'When the user is developer' do
      before 'developer must Sign-in' do
        sign_in developer
        get :index, params: { project_id: project.id }
      end

      it 'renders a template of index' do
        expect(subject).to render_template('index')
        expect(response.status).to eq 200
      end
    end
  end

  describe 'Get Bug#new' do
    context 'when user is manager' do
      before 'manager must be signed in' do
        sign_in qa
        get :new, params: { project_id: project.id }
      end

      it 'render new template' do
        expect(subject).to render_template('new')
      end
    end

    context 'User signed in as Developer' do
      before 'developer must sign in' do
        sign_in developer
        get :new, params: { project_id: project.id }
      end

      it 'shows a flash of not authorized' do
        flash[:alert] = 'You are not authorized to perform this action'
      end
    end

    context 'User signed in as manager' do
      before 'manager must sign in' do
        sign_in manager
        get :new, params: { project_id: project.id }
      end

      it 'shows a flash of not authorized' do
        flash[:alert] = 'You are not authorized to perform this action'
      end
    end
  end

  describe 'POST Bug#create' do
    context 'when user is qa' do
      context 'bug create with valid params' do
        it 'creates a bug' do
          get :new, params: { project_id: project.id }
          expect do
            post :create, params: { bug: set_params, project_id: project.id }
          end.to change(Bug, :count).by(1)
          expect(flash[:notice]).to eq(I18n.t('create'))
        end
      end

      context 'Invalid case for create' do
        it 'not destroying the bug' do
          post :create, params: { bug: bug_invalid_params, project_id: project.id }
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe 'PUT Bug#update' do
    context 'user signed in as qa' do
      before 'qa must be signed in' do
        sign_in bug.posted_by
      end

      context 'bug updated with valid params' do
        before do
          patch :update, params: {

            bug: set_params,
            id: bug.id,
            project_id: bug.project_id
          }
        end

        it 'updates the bug and redirect to updated post' do
          expect(response.status).to eq 302
          expect(flash[:notice]).to eq(I18n.t('update'))
        end
      end

      context 'Invalid case for update' do
        it 'not destroying the bug' do
          Bug.any_instance.stub(:save).and_return(false)
          patch :update, params: { bug: bug_invalid_params, id: bug.id, project_id: bug.project_id }
          expect(response).to render_template('edit')
        end
      end
    end
  end

  describe 'Patch Bug#status' do
    context 'user is logged in as developer' do
      before 'developer must sign-in' do
        sign_in bug.assigned_to
      end

      context 'bug updated with valid params' do
        it 'change status' do
          patch :status, params: {

            status: 'Resolved',
            id: bug.id,
            project_id: bug.project_id
          }
          bug.reload
          expect(bug.status).to eq('Resolved')
          expect(flash[:notice]).to eq('Bug updated')
        end

        context 'Invalid case for status' do
          it 'not updating status' do
            post :status, params: { id: bug.id, status: nil, project_id: bug.project_id }
            expect(flash[:alert]).to eq('Status not updated')
          end
        end

        context 'User signed in as manager' do
          before 'manager must sign in' do
            sign_in manager
            patch :status, params: {

              status: 'Resolved',
              id: bug.id,
              project_id: bug.project_id
            }
          end

          it 'shows a flash of not authorized' do
            flash[:alert] = 'You are not authorized to perform this action'
          end
        end

        context 'User signed in as qa' do
          before 'qa must sign in' do
            sign_in qa
            patch :status, params: {

              status: 'Resolved',
              id: bug.id,
              project_id: bug.project_id
            }
          end

          it 'shows a flash of not authorized' do
            flash[:alert] = 'You are not authorized to perform this action'
          end
        end
      end
    end
  end
end
