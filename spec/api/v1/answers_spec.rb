require 'rails_helper'

describe 'Answers API', type: :request do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  describe 'GET /api/v1/questions/:question_id/answers' do
    let!(:question) { create(:question) }
    let!(:answers) { create_list(:answer, 3, question: question) }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answer_response) { json['answers'].first }
      let(:answer) { answers.first }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 status' do
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /api/v1/answers/:id' do
    let!(:answer) { create(:answer) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answer_response) { json['answer'] }
      let!(:links) { create_list(:link, 2, linkable: answer) }
      let(:user) { create(:user) }
      let!(:comments) { create_list(:comment, 2, commentable: answer, user: user) }

      before do
        answer.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'rails_helper.rb')
        answer.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'spec_helper.rb')

        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it_behaves_like 'API Commentable' do
        let(:commentable_response) { answer_response['comments'] }
      end

      it_behaves_like 'API Fileable' do
        let(:fileable_response) { answer_response['files'] }
      end
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }

    let(:access_token) { create(:access_token) }
    let(:answer) { create(:answer, user_id: access_token.resource_owner_id) }

    let(:valid_attributes) { { access_token: access_token.token, answer: attributes_for(:answer) } }
    let(:invalid_attributes) { { access_token: access_token.token, answer: attributes_for(:answer, :invalid) } }

    let(:method) { :patch }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      context 'author' do
        context 'with valid attributes' do
          it 'edits the answer' do
            do_request(method, api_path, params: valid_attributes, headers: headers)
            answer.reload
            expect(answer.body).to eq valid_attributes[:answer][:body]
          end

          it 'returns status 200' do
            do_request(method, api_path, params: valid_attributes, headers: headers)
            answer.reload
            expect(response).to be_successful
          end
        end

        context 'with invalid attributes' do
          it "doesn't edits the answer" do
            do_request(method, api_path, params: invalid_attributes, headers: headers)
            answer.reload
            expect(answer.body).to_not eq invalid_attributes[:answer][:body]
          end

          it 'returns unprocessable_entity(422)' do
            do_request(method, api_path, params: invalid_attributes, headers: headers)
            answer.reload
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'not author' do
        let(:answer) { create(:answer) }

        it "doesn't edits the answer" do
          do_request(method, api_path, params: { access_token: access_token.token, answer: { body: 'new body' } },
                                       headers: headers)
          answer.reload
          expect(answer.body).to_not eq 'new body'
        end
      end
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }

    let(:access_token) { create(:access_token) }
    let(:answer) { create(:answer, user_id: access_token.resource_owner_id) }
    let(:method) { :delete }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      context 'author' do
        it 'deletes the answer' do
          expect do
            do_request(method, api_path, params: { access_token: access_token.token },
                                         headers: headers)
          end.to change(answer.user.answers, :count).by(-1)
        end

        it 'returns status 200' do
          do_request(method, api_path, params: { access_token: access_token.token }, headers: headers)
          expect(response).to be_successful
        end
      end

      context 'not author' do
        let(:answer) { create(:answer) }
        it "doesn't deletes the answer" do
          expect do
            do_request(method, api_path, params: { access_token: access_token.token },
                                         headers: headers)
          end.to_not change(answer.user.answers, :count)
        end
      end
    end
  end
end
