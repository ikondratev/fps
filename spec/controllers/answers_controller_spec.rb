require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create(:question) }
  let!(:answer) { create(:answer) }
  let(:user) { create(:user) }

  describe 'POST #create' do
    let(:valid_create_answer) do
      post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
    end

    let(:invalid_create_answer) do
      post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }, format: :js
    end

    before { login(user) }

    context 'with valid attributes' do
      it 'saved new answer in db' do
        expect { valid_create_answer }.to change(question.answers, :count).by(1)
      end

      it 'redirects to associated question' do
        valid_create_answer
        expect(response).to render_template :create
      end

      it 'associated answer with current user' do
        valid_create_answer
        expect(assigns(:answer).user_id).to eq user.id
      end
    end

    context 'with invalid attributes' do
      it 'doesnt save invalid answer in db' do
        expect { invalid_create_answer }.to_not change(Answer, :count)
      end

      it 're randers create view' do
        invalid_create_answer
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    let!(:answer) { create(:answer, question: question) }

    context 'with valid attributes' do
      before do
        sign_in(answer.user)
        patch :update, params: { id: answer, answer: { body: 'My updated body' }, format: :js }
      end

      it 'changes answers body' do
        answer.reload
        expect(answer.body).to eq 'My updated body'
      end

      it 'rendered update view' do
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      before do
        sign_in(answer.user)
        patch :update, params: { id: answer, question_id: question, answer: attributes_for(:answer, :invalid), format: :js }
      end

      it 'not changes answers body' do
        answer.reload
        expect(answer.body).to eq answer.body
      end

      it 'rendered update view' do
        expect(response).to render_template :update
      end
    end
  end

  describe 'DELETE #destroy' do
    before { answer }

    let(:delete_answer) { delete :destroy, params: { question_id: answer.question.id, id: answer }, format: :js }

    context 'if it is an author of answer' do
      before { login answer.user }

      it 'deletes an answer' do
        expect { delete_answer }.to change(Answer, :count).by(-1)
      end

      it 're-directs to question' do
        delete_answer
        expect(response).to render_template :destroy
      end
    end

    context 'if it is not an author of answer' do
      before { login(user) }

      it 'doesnt delete asnwer' do
        expect { delete_answer }.not_to change(Answer, :count)
      end

      it 're-directs to question' do
        delete_answer
        expect(response).to render_template :destroy
      end
    end
  end

  describe 'PATCH #set_the_best' do
    let!(:question_with_answer) { create(:question, :with_answer) }
    let(:best_answer) { question_with_answer.answers[1] }

    context 'user as an author sets the best answer' do
      before do
        sign_in(question_with_answer.user)
        patch :set_the_best, params: { id: best_answer }, format: :js
      end

      it 'set the best attributes to answer' do
        expect(assigns(:answer).the_best).to eq(true)
      end

      it 'render templete' do
        expect(response).to render_template :set_the_best
      end
    end

    context 'user as not an author tries to select set answer' do
      it 'does not set the best answer' do
        sign_in(user)

        patch :set_the_best, params: { id: best_answer }, format: :js

        expect(assigns(:answer).the_best).to_not eq(true)
      end
    end
  end
end
