require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create(:question) }
  let(:user) { create(:user) }
  let(:not_author) { create(:user) }

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new answer in the DB' do
        expect do
          post :create,
               params: { answer: attributes_for(:answer), question_id: question, format: :js }
        end.to change(user.answers, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new answer in the DB' do
        expect do
          post :create,
               params: { answer: attributes_for(:answer, :invalid), question_id: question, format: :js }
        end.to_not change(question.answers, :count)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:answer) { create(:answer, question: question, user: user) }

    context 'by author with valid attributes' do
      before { login(user) }

      it 'changes answer attributes' do
        patch :update, params: { id: answer, answer: { body: 'edited answer' }, format: :js }
        answer.reload
        expect(answer.body).to eq 'edited answer'
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: { body: 'edited answer' }, format: :js }
        expect(response).to render_template :update
      end
    end

    context 'by author with invalid attributes' do
      before { login(user) }

      it 'doesnt change answer attributes' do
        expect do
          patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid), format: :js }
        end.to_not change(answer, :body)
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid), format: :js }
        expect(response).to render_template :update
      end
    end

    context 'by not author' do
      before { login(not_author) }

      it 'doesnt change answer attributes' do
        expect do
          patch :update, params: { id: answer, answer: { body: 'edited answer' }, format: :js }
        end.to_not change(answer, :body)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:answer) { create(:answer) }

    context 'user is an author' do
      before { login(answer.user) }

      it 'deletes the answer' do
        expect do
          delete :destroy, params: { question_id: question, id: answer, format: :js }
        end.to change(Answer, :count).by(-1)
      end

      it 'redirects to questions' do
        delete :destroy, params: { id: answer }, format: :js
        expect(response).to render_template :destroy
      end
    end
  end
end
